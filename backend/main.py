import uuid
from contextlib import asynccontextmanager
from datetime import datetime, timedelta
from typing import Optional

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware

from database import get_connection, init_db
from models import (
    BudgetCreate,
    BudgetResponse,
    BudgetUpdate,
    CategoryStat,
    ExpenseCreate,
    ExpenseResponse,
    ExpenseUpdate,
    MonthlyTrend,
    RecurringCreate,
    RecurringResponse,
    RecurringUpdate,
    StatsResponse,
)


@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()
    yield


app = FastAPI(title="Expense Tracker API", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


# ─── Helpers ───


def _expense_from_row(r) -> ExpenseResponse:
    return ExpenseResponse(
        id=r["id"],
        title=r["title"],
        amount=r["amount"],
        category=r["category"],
        date=datetime.fromisoformat(r["date"]),
    )


# ─── Expenses ───


@app.get("/api/expenses", response_model=list)
def list_expenses(
    search: Optional[str] = Query(None),
    category: Optional[str] = Query(None),
    from_date: Optional[str] = Query(None),
    to_date: Optional[str] = Query(None),
):
    conn = get_connection()
    query = "SELECT * FROM expenses WHERE 1=1"
    params = []

    if search:
        query += " AND title LIKE ?"
        params.append(f"%{search}%")
    if category:
        query += " AND category = ?"
        params.append(category)
    if from_date:
        query += " AND date >= ?"
        params.append(from_date)
    if to_date:
        query += " AND date <= ?"
        params.append(to_date)

    query += " ORDER BY date DESC"
    rows = conn.execute(query, params).fetchall()
    conn.close()
    return [_expense_from_row(r) for r in rows]


@app.get("/api/expenses/{expense_id}", response_model=ExpenseResponse)
def get_expense(expense_id: str):
    conn = get_connection()
    row = conn.execute(
        "SELECT * FROM expenses WHERE id = ?", (expense_id,)
    ).fetchone()
    conn.close()
    if not row:
        raise HTTPException(status_code=404, detail="Expense not found")
    return _expense_from_row(row)


@app.post("/api/expenses", response_model=ExpenseResponse, status_code=201)
def create_expense(expense: ExpenseCreate):
    expense_id = uuid.uuid4().hex
    conn = get_connection()
    conn.execute(
        "INSERT INTO expenses (id, title, amount, category, date) VALUES (?, ?, ?, ?, ?)",
        (expense_id, expense.title, expense.amount, expense.category, expense.date.isoformat()),
    )
    conn.commit()
    conn.close()
    return ExpenseResponse(id=expense_id, **expense.model_dump())


@app.put("/api/expenses/{expense_id}", response_model=ExpenseResponse)
def update_expense(expense_id: str, updates: ExpenseUpdate):
    conn = get_connection()
    row = conn.execute("SELECT * FROM expenses WHERE id = ?", (expense_id,)).fetchone()
    if not row:
        conn.close()
        raise HTTPException(status_code=404, detail="Expense not found")

    current = dict(row)
    for field, value in updates.model_dump(exclude_none=True).items():
        if field == "date" and value is not None:
            current[field] = value.isoformat()
        else:
            current[field] = value

    conn.execute(
        "UPDATE expenses SET title=?, amount=?, category=?, date=? WHERE id=?",
        (current["title"], current["amount"], current["category"], current["date"], expense_id),
    )
    conn.commit()
    conn.close()
    return ExpenseResponse(
        id=expense_id,
        title=current["title"],
        amount=current["amount"],
        category=current["category"],
        date=datetime.fromisoformat(current["date"]),
    )


@app.delete("/api/expenses/{expense_id}", status_code=204)
def delete_expense(expense_id: str):
    conn = get_connection()
    result = conn.execute("DELETE FROM expenses WHERE id = ?", (expense_id,))
    conn.commit()
    conn.close()
    if result.rowcount == 0:
        raise HTTPException(status_code=404, detail="Expense not found")


# ─── Stats ───


@app.get("/api/stats/monthly", response_model=StatsResponse)
def monthly_stats(
    year: int = Query(...),
    month: int = Query(..., ge=1, le=12),
):
    conn = get_connection()
    start = f"{year:04d}-{month:02d}-01"
    if month == 12:
        end = f"{year + 1:04d}-01-01"
    else:
        end = f"{year:04d}-{month + 1:02d}-01"

    rows = conn.execute(
        "SELECT category, SUM(amount) as total, COUNT(*) as count "
        "FROM expenses WHERE date >= ? AND date < ? GROUP BY category ORDER BY total DESC",
        (start, end),
    ).fetchall()
    conn.close()

    grand_total = sum(r["total"] for r in rows)
    grand_count = sum(r["count"] for r in rows)

    categories = [
        CategoryStat(
            category=r["category"],
            total=r["total"],
            count=r["count"],
            percentage=(r["total"] / grand_total * 100) if grand_total > 0 else 0,
        )
        for r in rows
    ]

    return StatsResponse(total=grand_total, count=grand_count, categories=categories)


@app.get("/api/stats/trend", response_model=list)
def spending_trend(months: int = Query(6, ge=1, le=24)):
    conn = get_connection()
    now = datetime.now()
    results = []

    for i in range(months - 1, -1, -1):
        y = now.year
        m = now.month - i
        while m <= 0:
            m += 12
            y -= 1
        start = f"{y:04d}-{m:02d}-01"
        if m == 12:
            end = f"{y + 1:04d}-01-01"
        else:
            end = f"{y:04d}-{m + 1:02d}-01"

        row = conn.execute(
            "SELECT COALESCE(SUM(amount), 0) as total FROM expenses WHERE date >= ? AND date < ?",
            (start, end),
        ).fetchone()
        results.append(MonthlyTrend(month=f"{y:04d}-{m:02d}", total=row["total"]))

    conn.close()
    return results


# ─── Budgets ───


@app.get("/api/budgets", response_model=list)
def list_budgets():
    conn = get_connection()
    budgets = conn.execute("SELECT * FROM budgets ORDER BY category").fetchall()

    now = datetime.now()
    start = f"{now.year:04d}-{now.month:02d}-01"
    if now.month == 12:
        end = f"{now.year + 1:04d}-01-01"
    else:
        end = f"{now.year:04d}-{now.month + 1:02d}-01"

    results = []
    for b in budgets:
        row = conn.execute(
            "SELECT COALESCE(SUM(amount), 0) as spent FROM expenses WHERE category = ? AND date >= ? AND date < ?",
            (b["category"], start, end),
        ).fetchone()
        spent = row["spent"]
        limit = b["monthly_limit"]
        results.append(
            BudgetResponse(
                id=b["id"],
                category=b["category"],
                monthly_limit=limit,
                spent=spent,
                remaining=max(0, limit - spent),
                percentage_used=(spent / limit * 100) if limit > 0 else 0,
                created_at=datetime.fromisoformat(b["created_at"]),
            )
        )
    conn.close()
    return results


@app.post("/api/budgets", response_model=BudgetResponse, status_code=201)
def create_budget(budget: BudgetCreate):
    conn = get_connection()
    existing = conn.execute("SELECT id FROM budgets WHERE category = ?", (budget.category,)).fetchone()
    if existing:
        conn.close()
        raise HTTPException(status_code=409, detail="Budget for this category already exists")

    budget_id = uuid.uuid4().hex
    now = datetime.now()
    conn.execute(
        "INSERT INTO budgets (id, category, monthly_limit, created_at) VALUES (?, ?, ?, ?)",
        (budget_id, budget.category, budget.monthly_limit, now.isoformat()),
    )
    conn.commit()
    conn.close()
    return BudgetResponse(
        id=budget_id,
        category=budget.category,
        monthly_limit=budget.monthly_limit,
        spent=0,
        remaining=budget.monthly_limit,
        percentage_used=0,
        created_at=now,
    )


@app.put("/api/budgets/{budget_id}", response_model=BudgetResponse)
def update_budget(budget_id: str, updates: BudgetUpdate):
    conn = get_connection()
    row = conn.execute("SELECT * FROM budgets WHERE id = ?", (budget_id,)).fetchone()
    if not row:
        conn.close()
        raise HTTPException(status_code=404, detail="Budget not found")

    new_limit = updates.monthly_limit if updates.monthly_limit is not None else row["monthly_limit"]
    conn.execute("UPDATE budgets SET monthly_limit=? WHERE id=?", (new_limit, budget_id))
    conn.commit()

    now = datetime.now()
    start = f"{now.year:04d}-{now.month:02d}-01"
    if now.month == 12:
        end = f"{now.year + 1:04d}-01-01"
    else:
        end = f"{now.year:04d}-{now.month + 1:02d}-01"

    spent_row = conn.execute(
        "SELECT COALESCE(SUM(amount), 0) as spent FROM expenses WHERE category = ? AND date >= ? AND date < ?",
        (row["category"], start, end),
    ).fetchone()
    spent = spent_row["spent"]
    conn.close()

    return BudgetResponse(
        id=budget_id,
        category=row["category"],
        monthly_limit=new_limit,
        spent=spent,
        remaining=max(0, new_limit - spent),
        percentage_used=(spent / new_limit * 100) if new_limit > 0 else 0,
        created_at=datetime.fromisoformat(row["created_at"]),
    )


@app.delete("/api/budgets/{budget_id}", status_code=204)
def delete_budget(budget_id: str):
    conn = get_connection()
    result = conn.execute("DELETE FROM budgets WHERE id = ?", (budget_id,))
    conn.commit()
    conn.close()
    if result.rowcount == 0:
        raise HTTPException(status_code=404, detail="Budget not found")


# ─── Recurring Expenses ───


@app.get("/api/recurring", response_model=list)
def list_recurring():
    conn = get_connection()
    rows = conn.execute("SELECT * FROM recurring_expenses ORDER BY next_due_date").fetchall()
    conn.close()
    return [
        RecurringResponse(
            id=r["id"],
            title=r["title"],
            amount=r["amount"],
            category=r["category"],
            frequency=r["frequency"],
            next_due_date=datetime.fromisoformat(r["next_due_date"]),
            is_active=bool(r["is_active"]),
            created_at=datetime.fromisoformat(r["created_at"]),
        )
        for r in rows
    ]


@app.post("/api/recurring", response_model=RecurringResponse, status_code=201)
def create_recurring(recurring: RecurringCreate):
    rec_id = uuid.uuid4().hex
    now = datetime.now()
    conn = get_connection()
    conn.execute(
        "INSERT INTO recurring_expenses (id, title, amount, category, frequency, next_due_date, is_active, created_at) "
        "VALUES (?, ?, ?, ?, ?, ?, 1, ?)",
        (rec_id, recurring.title, recurring.amount, recurring.category,
         recurring.frequency, recurring.next_due_date.isoformat(), now.isoformat()),
    )
    conn.commit()
    conn.close()
    return RecurringResponse(
        id=rec_id, is_active=True, created_at=now, **recurring.model_dump()
    )


@app.put("/api/recurring/{recurring_id}", response_model=RecurringResponse)
def update_recurring(recurring_id: str, updates: RecurringUpdate):
    conn = get_connection()
    row = conn.execute("SELECT * FROM recurring_expenses WHERE id = ?", (recurring_id,)).fetchone()
    if not row:
        conn.close()
        raise HTTPException(status_code=404, detail="Recurring expense not found")

    current = dict(row)
    for field, value in updates.model_dump(exclude_none=True).items():
        if field in ("next_due_date",) and value is not None:
            current[field] = value.isoformat()
        elif field == "is_active":
            current[field] = 1 if value else 0
        else:
            current[field] = value

    conn.execute(
        "UPDATE recurring_expenses SET title=?, amount=?, category=?, frequency=?, next_due_date=?, is_active=? WHERE id=?",
        (current["title"], current["amount"], current["category"], current["frequency"],
         current["next_due_date"], current["is_active"], recurring_id),
    )
    conn.commit()
    conn.close()
    return RecurringResponse(
        id=recurring_id,
        title=current["title"],
        amount=current["amount"],
        category=current["category"],
        frequency=current["frequency"],
        next_due_date=datetime.fromisoformat(current["next_due_date"]),
        is_active=bool(current["is_active"]),
        created_at=datetime.fromisoformat(current["created_at"]),
    )


@app.delete("/api/recurring/{recurring_id}", status_code=204)
def delete_recurring(recurring_id: str):
    conn = get_connection()
    result = conn.execute("DELETE FROM recurring_expenses WHERE id = ?", (recurring_id,))
    conn.commit()
    conn.close()
    if result.rowcount == 0:
        raise HTTPException(status_code=404, detail="Recurring expense not found")


@app.post("/api/recurring/{recurring_id}/trigger", response_model=ExpenseResponse)
def trigger_recurring(recurring_id: str):
    """Manually create an expense from a recurring template and advance the due date."""
    conn = get_connection()
    row = conn.execute("SELECT * FROM recurring_expenses WHERE id = ?", (recurring_id,)).fetchone()
    if not row:
        conn.close()
        raise HTTPException(status_code=404, detail="Recurring expense not found")

    expense_id = uuid.uuid4().hex
    now = datetime.now()
    conn.execute(
        "INSERT INTO expenses (id, title, amount, category, date) VALUES (?, ?, ?, ?, ?)",
        (expense_id, row["title"], row["amount"], row["category"], now.isoformat()),
    )

    # Advance next_due_date
    due = datetime.fromisoformat(row["next_due_date"])
    freq = row["frequency"]
    if freq == "daily":
        next_due = due + timedelta(days=1)
    elif freq == "weekly":
        next_due = due + timedelta(weeks=1)
    elif freq == "monthly":
        m = due.month + 1
        y = due.year
        if m > 12:
            m = 1
            y += 1
        next_due = due.replace(year=y, month=m)
    elif freq == "yearly":
        next_due = due.replace(year=due.year + 1)
    else:
        next_due = due + timedelta(days=30)

    conn.execute(
        "UPDATE recurring_expenses SET next_due_date=? WHERE id=?",
        (next_due.isoformat(), recurring_id),
    )
    conn.commit()
    conn.close()

    return ExpenseResponse(
        id=expense_id,
        title=row["title"],
        amount=row["amount"],
        category=row["category"],
        date=now,
    )
