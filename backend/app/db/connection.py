import psycopg # type: ignore
from core.config import conn_params
def connection_to_db():
    return psycopg.connect(**conn_params)
    
