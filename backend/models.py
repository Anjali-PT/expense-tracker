from typing import Optional, List

from pydantic import BaseModel, Field
from datetime import datetime


# --- Expenses ---

class ExpenseCreate(BaseModel):
    title: str = Field(min_length=1)
    amount: float = Field(gt=0)
    category: str = Field(min_length=1)
    date: datetime


class ExpenseUpdate(BaseModel):
    title: Optional[str] = None
    amount: Optional[float] = Field(default=None, gt=0)
    category: Optional[str] = None
    date: Optional[datetime] = None


class ExpenseResponse(BaseModel):
    id: str
    title: str
    amount: float
    category: str
    date: datetime


# --- Stats ---

class CategoryStat(BaseModel):
    category: str
    total: float
    count: int
    percentage: float


class MonthlyTrend(BaseModel):
    month: str
    total: float


class StatsResponse(BaseModel):
    total: float
    count: int
    categories: List[CategoryStat]


# --- Budgets ---

class BudgetCreate(BaseModel):
    category: str = Field(min_length=1)
    monthly_limit: float = Field(gt=0)


class BudgetUpdate(BaseModel):
    monthly_limit: Optional[float] = Field(default=None, gt=0)


class BudgetResponse(BaseModel):
    id: str
    category: str
    monthly_limit: float
    spent: float
    remaining: float
    percentage_used: float
    created_at: datetime


# --- Recurring Expenses ---

class RecurringCreate(BaseModel):
    title: str = Field(min_length=1)
    amount: float = Field(gt=0)
    category: str = Field(min_length=1)
    frequency: str = Field(pattern=r"^(daily|weekly|monthly|yearly)$")
    next_due_date: datetime


class RecurringUpdate(BaseModel):
    title: Optional[str] = None
    amount: Optional[float] = Field(default=None, gt=0)
    category: Optional[str] = None
    frequency: Optional[str] = Field(default=None, pattern=r"^(daily|weekly|monthly|yearly)$")
    next_due_date: Optional[datetime] = None
    is_active: Optional[bool] = None


class RecurringResponse(BaseModel):
    id: str
    title: str
    amount: float
    category: str
    frequency: str
    next_due_date: datetime
    is_active: bool
    created_at: datetime
