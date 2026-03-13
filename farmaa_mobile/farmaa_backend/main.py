"""Farmaa API – Production-ready FastAPI backend.

Deployed on Vercel (serverless) and Render with Supabase PostgreSQL.
"""

import traceback
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from database import Base, get_engine
from routers import auth_router, crops_router, orders_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Create tables on startup. Graceful if DB is temporarily unreachable."""
    eng = get_engine()
    if eng is not None:
        try:
            Base.metadata.create_all(bind=eng)
            print("[Farmaa] Database tables verified ✓")
        except Exception as e:
            print(f"[Farmaa] WARNING: Could not connect to DB on startup: {e}")
            print("[Farmaa] The app will start anyway. DB calls will retry on each request.")
    else:
        print("[Farmaa] WARNING: No DATABASE_URL configured. Running without database.")
    yield


# ── App ──
app = FastAPI(
    title="Farmaa API",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

# ── CORS – allow mobile access from any origin ──
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)

# ── Routers ──
app.include_router(auth_router.router)
app.include_router(crops_router.router)
app.include_router(orders_router.router)


# ── Global Exception Handler ──
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    traceback.print_exc()
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error. Please try again later."},
    )


# ── Health Check ──
@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/")
def root():
    return {
        "name": "Farmaa API",
        "version": "1.0.0",
        "status": "online",
        "docs": "/docs",
    }
