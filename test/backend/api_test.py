"""Backend API integration tests."""
import json
import subprocess
import sys
import time
import urllib.request
import urllib.error

BASE_URL = "http://localhost:8080/api"


def request(method, path, data=None):
    url = f"{BASE_URL}{path}"
    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(url, data=body, method=method)
    if data:
        req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req) as resp:
            if resp.status == 204:
                return None
            return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        return {"error": e.code, "detail": json.loads(e.read())}


def test_expense_crud():
    # Create
    expense = request("POST", "/expenses", {
        "title": "Test Coffee",
        "amount": 4.50,
        "category": "Food & Dining",
        "date": "2026-03-26T08:00:00",
    })
    assert expense["title"] == "Test Coffee"
    assert expense["amount"] == 4.50
    expense_id = expense["id"]

    # Read
    fetched = request("GET", f"/expenses/{expense_id}")
    assert fetched["id"] == expense_id

    # Update
    updated = request("PUT", f"/expenses/{expense_id}", {
        "title": "Updated Coffee",
        "amount": 5.00,
    })
    assert updated["title"] == "Updated Coffee"
    assert updated["amount"] == 5.00

    # List
    expenses = request("GET", "/expenses")
    assert any(e["id"] == expense_id for e in expenses)

    # Search
    searched = request("GET", "/expenses?search=Updated")
    assert len(searched) >= 1

    # Delete
    request("DELETE", f"/expenses/{expense_id}")

    print("  PASS: expense CRUD")


def test_budget_crud():
    budget = request("POST", "/budgets", {
        "category": "Test Budget Cat",
        "monthly_limit": 500.0,
    })
    assert budget["monthly_limit"] == 500.0
    budget_id = budget["id"]

    budgets = request("GET", "/budgets")
    assert any(b["id"] == budget_id for b in budgets)

    updated = request("PUT", f"/budgets/{budget_id}", {
        "monthly_limit": 600.0,
    })
    assert updated["monthly_limit"] == 600.0

    request("DELETE", f"/budgets/{budget_id}")

    print("  PASS: budget CRUD")


def test_recurring_crud():
    rec = request("POST", "/recurring", {
        "title": "Test Sub",
        "amount": 9.99,
        "category": "Entertainment",
        "frequency": "monthly",
        "next_due_date": "2026-04-01T00:00:00",
    })
    assert rec["title"] == "Test Sub"
    rec_id = rec["id"]

    items = request("GET", "/recurring")
    assert any(r["id"] == rec_id for r in items)

    # Trigger creates an expense
    triggered = request("POST", f"/recurring/{rec_id}/trigger")
    assert triggered["title"] == "Test Sub"

    request("DELETE", f"/recurring/{rec_id}")

    print("  PASS: recurring CRUD")


def test_stats():
    # Create an expense for stats
    expense = request("POST", "/expenses", {
        "title": "Stats Test",
        "amount": 25.0,
        "category": "Food & Dining",
        "date": "2026-03-15T12:00:00",
    })

    stats = request("GET", "/stats/monthly?year=2026&month=3")
    assert stats["total"] > 0
    assert len(stats["categories"]) > 0

    trend = request("GET", "/stats/trend?months=3")
    assert len(trend) == 3

    request("DELETE", f"/expenses/{expense['id']}")

    print("  PASS: stats endpoints")


if __name__ == "__main__":
    print("Running backend API tests...")
    test_expense_crud()
    test_budget_crud()
    test_recurring_crud()
    test_stats()
    print("\nAll backend tests passed!")
