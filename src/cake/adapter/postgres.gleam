//// PostgreSQL adapter which which passes `PreparedStatements`
//// to the `gleam_pgo` library for execution.
////

// TODO v1 Add pluggable logging, remove default logging

// TODO v2 transactions and collecting their errors?

import cake/internal/database_adapter.{PostgresAdapter}
import cake/internal/prepared_statement.{type PreparedStatement}
import cake/internal/query.{type Query}
import cake/internal/stdlib/iox
import cake/internal/write_query.{type WriteQuery}
import cake/param.{
  type Param, BoolParam, FloatParam, IntParam, NullParam, StringParam,
}
import gleam/dynamic
import gleam/list
import gleam/pgo.{type Connection, type Value}

const placeholder_prefix = "$"

pub fn to_prepared_statement(query qry: Query) -> PreparedStatement {
  qry
  |> query.to_prepared_statement(
    placeholder_prefix: placeholder_prefix,
    database_adapter: PostgresAdapter,
  )
}

pub fn write_query_to_prepared_statement(
  query qry: WriteQuery(t),
) -> PreparedStatement {
  qry
  |> write_query.to_prepared_statement(
    placeholder_prefix: placeholder_prefix,
    database_adapter: PostgresAdapter,
  )
}

pub fn with_connection(f: fn(Connection) -> a) -> a {
  let connection =
    pgo.connect(
      pgo.Config(
        ..pgo.default_config(),
        host: "localhost",
        database: "gleam_cake",
      ),
    )

  let value = f(connection)
  pgo.disconnect(connection)

  value
}

pub fn run_query(query qry: Query, decoder dcdr, db_connection db_conn) {
  let prp_stm = to_prepared_statement(qry)
  let sql = prepared_statement.get_sql(prp_stm) |> iox.inspect_println_tap

  let params = prepared_statement.get_params(prp_stm)

  let db_params =
    params
    |> list.map(fn(param: Param) -> Value {
      case param {
        BoolParam(param) -> pgo.bool(param)
        FloatParam(param) -> pgo.float(param)
        IntParam(param) -> pgo.int(param)
        StringParam(param) -> pgo.text(param)
        NullParam -> pgo.null()
      }
    })
    |> iox.print_tap("Params: ")
    |> iox.inspect_println_tap

  let result = sql |> pgo.execute(on: db_conn, with: db_params, expecting: dcdr)

  case result {
    Ok(pgo.Returned(_result_count, v)) -> Ok(v)
    Error(e) -> Error(e)
  }
}

pub fn run_write(query qry: WriteQuery(t), decoder dcdr, db_connection db_conn) {
  let prp_stm = write_query_to_prepared_statement(qry)
  let sql = prepared_statement.get_sql(prp_stm) |> iox.inspect_println_tap

  let params = prepared_statement.get_params(prp_stm)

  let db_params =
    params
    |> list.map(fn(param: Param) -> Value {
      case param {
        // If all we need is this, use based library
        BoolParam(param) -> pgo.bool(param)
        FloatParam(param) -> pgo.float(param)
        IntParam(param) -> pgo.int(param)
        StringParam(param) -> pgo.text(param)
        NullParam -> pgo.null()
      }
    })
    |> iox.print_tap("Params: ")
    |> iox.inspect_println_tap

  let result = sql |> pgo.execute(on: db_conn, with: db_params, expecting: dcdr)

  case result {
    Ok(pgo.Returned(_result_count, v)) -> Ok(v)
    Error(e) -> Error(e)
  }
}

pub fn execute_raw_sql(query qry: String, connection conn: Connection) {
  qry |> pgo.execute(conn, with: [], expecting: dynamic.dynamic)
}
