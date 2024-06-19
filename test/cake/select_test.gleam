import birdie
import cake/query/fragment as frgmt
import cake/query/from as f
import cake/query/select as s
import pprint.{format as to_string}
import test_helper/postgres_test_helper
import test_helper/sqlite_test_helper
import test_support/dialect/postgres
import test_support/dialect/sqlite

const const_field = "age"

fn select_query() {
  s.new_from(f.table("cats"))
  |> s.selects([
    s.col("name"),
    // TODO v1 check if this should work AT ALL, because it does not work in postgres
    // s.bool(True),
    // s.float(1.0),
    // s.int(1),
    s.string("hello"),
    s.fragment(frgmt.literal(const_field)),
    s.alias(s.col("age"), "years_since_birth"),
  ])
  |> s.to_query
}

pub fn select_test() {
  select_query()
  |> to_string
  |> birdie.snap("select_test")
}

pub fn select_prepared_statement_test() {
  let pgo = select_query() |> postgres.to_prepared_statement
  let lit = select_query() |> sqlite.to_prepared_statement

  #(pgo, lit)
  |> to_string
  |> birdie.snap("select_prepared_statement_test")
}

pub fn select_execution_result_test() {
  let pgo = select_query() |> postgres_test_helper.setup_and_run
  let lit = select_query() |> sqlite_test_helper.setup_and_run

  #(pgo, lit)
  |> to_string
  |> birdie.snap("select_execution_result_test")
}

fn select_distinct_query() {
  s.new_from(f.table("cats"))
  |> s.distinct
  |> s.selects([s.col("is_wild")])
  |> s.order_asc("is_wild")
  |> s.to_query
}

pub fn select_distinct_test() {
  select_distinct_query()
  |> to_string
  |> birdie.snap("select_distinct_test")
}

pub fn select_distinct_prepared_statement_test() {
  let pgo = select_distinct_query() |> postgres.to_prepared_statement
  let lit = select_distinct_query() |> sqlite.to_prepared_statement

  #(pgo, lit)
  |> to_string
  |> birdie.snap("select_distinct_prepared_statement_test")
}

pub fn select_distinct_execution_result_test() {
  let pgo = select_distinct_query() |> postgres_test_helper.setup_and_run
  let lit = select_distinct_query() |> sqlite_test_helper.setup_and_run

  #(pgo, lit)
  |> to_string
  |> birdie.snap("select_distinct_execution_result_test")
}
