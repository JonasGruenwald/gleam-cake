//// A DSL to build `INSERT` queries.
////

import cake/internal/query.{type Where, Comment, NoComment}
import cake/internal/write_query.{
  type Insert, type InsertRow, type Update, type WriteQuery, Insert,
  InsertColumns, InsertConflictError, InsertConflictIgnore, InsertConflictTarget,
  InsertConflictTargetConstraint, InsertConflictUpdate, InsertIntoTable,
  InsertModifier, InsertQuery, InsertRow, InsertSourceRecords, InsertSourceRows,
  NoInsertModifier, NoReturning, Returning,
}
import gleam/string

pub fn to_query(insert: Insert(a)) -> WriteQuery(a) {
  insert |> InsertQuery
}

/// Create an `INSERT` query from a list of gleam records.
///
/// The `caster` function is used to convert each record into an `InsertRow`.
///
pub fn from_record(
  table_name tbl_nm: String,
  columns cols: List(String),
  records rcrds: List(a),
  caster cstr: fn(a) -> InsertRow,
) -> Insert(a) {
  Insert(
    into_table: InsertIntoTable(table: tbl_nm),
    modifier: NoInsertModifier,
    source: InsertSourceRecords(records: rcrds, caster: cstr),
    columns: InsertColumns(columns: cols),
    on_conflict: InsertConflictError,
    returning: NoReturning,
    comment: NoComment,
  )
}

/// Create an `INSERT` query from a list of `InsertRow`s.
///
pub fn from_values(
  table_name tbl_nm: String,
  columns cols: List(String),
  records rcrds: List(InsertRow),
) -> Insert(a) {
  Insert(
    into_table: InsertIntoTable(table: tbl_nm),
    modifier: NoInsertModifier,
    source: InsertSourceRows(records: rcrds),
    columns: InsertColumns(columns: cols),
    on_conflict: InsertConflictError,
    returning: NoReturning,
    comment: NoComment,
  )
}

pub fn into_table(query qry: Insert(a), table_name tbl_nm: String) -> Insert(a) {
  Insert(..qry, into_table: InsertIntoTable(table: tbl_nm))
}

pub fn modifier(query qry: Insert(a), modifier mdfr: String) -> Insert(a) {
  let mdfr = mdfr |> string.trim
  case mdfr {
    "" -> Insert(..qry, modifier: NoInsertModifier)
    _ -> Insert(..qry, modifier: InsertModifier(mdfr))
  }
}

pub fn no_modifier(query qry: Insert(a)) -> Insert(a) {
  Insert(..qry, modifier: NoInsertModifier)
}

pub fn source_records(
  query qry: Insert(a),
  source rcrds: List(a),
  caster cstr: fn(a) -> InsertRow,
) -> Insert(a) {
  Insert(..qry, source: InsertSourceRecords(records: rcrds, caster: cstr))
}

pub fn source_values(
  query qry: Insert(a),
  records rcrds: List(InsertRow),
) -> Insert(a) {
  Insert(..qry, source: InsertSourceRows(records: rcrds))
}

/// Specify the columns to insert into.
///
/// NOTICE: You have to specify the columns and keep track if their names are
///         correct, as well as their count which must be equal to the count of
///         `InsertRows` the caster function returns or is given as source
///          values.
///
pub fn columns(query qry: Insert(a), columns cols: List(String)) -> Insert(a) {
  Insert(..qry, columns: InsertColumns(columns: cols))
}

/// This specifies that any conflicts result in the query to fail
///
/// This is the default behaviour.
///
pub fn on_conflict_error(query qry: Insert(a)) -> Insert(a) {
  Insert(..qry, on_conflict: InsertConflictError)
}

/// This specifies that specific conflicts do not result in an error but instead
/// are just ignored and not inserted.
///
/// Conflict Target: Columns
///
pub fn on_columns_conflict_ignore(
  query qry: Insert(a),
  column cols: List(String),
  where whr: Where,
) -> Insert(a) {
  Insert(
    ..qry,
    on_conflict: InsertConflictIgnore(
      target: InsertConflictTarget(columns: cols),
      where: whr,
    ),
  )
}

/// This specifies that specific conflicts do not result in an error but instead
/// are just ignored and not inserted.
///
/// Conflict Target: Constraint
///
pub fn on_constraint_conflict_ignore(
  query qry: Insert(a),
  constraint cnstrt: String,
  where whr: Where,
) -> Insert(a) {
  Insert(
    ..qry,
    on_conflict: InsertConflictIgnore(
      target: InsertConflictTargetConstraint(constraint: cnstrt),
      where: whr,
    ),
  )
}

/// Inserts or updates on conflict, also called ´.UPSERT´.
///
/// Conflict Target: Columns
///
pub fn on_columns_conflict_update(
  query qry: Insert(a),
  column cols: List(String),
  where whr: Where,
  update updt: Update(a),
) -> Insert(a) {
  Insert(
    ..qry,
    on_conflict: InsertConflictUpdate(
      target: InsertConflictTarget(columns: cols),
      where: whr,
      update: updt,
    ),
  )
}

/// Inserts or updates on conflict, also called ´.UPSERT´.
///
/// Conflict Target: Constraint
///
pub fn on_constraint_conflict_update(
  query qry: Insert(a),
  constraint cnstrt: String,
  where whr: Where,
  update updt: Update(a),
) -> Insert(a) {
  Insert(
    ..qry,
    on_conflict: InsertConflictUpdate(
      target: InsertConflictTargetConstraint(constraint: cnstrt),
      where: whr,
      update: updt,
    ),
  )
}

pub fn returning(
  query qry: Insert(a),
  returning rtrn: List(String),
) -> Insert(a) {
  case rtrn {
    [] -> Insert(..qry, returning: NoReturning)
    _ -> Insert(..qry, returning: Returning(rtrn))
  }
}

pub fn no_returning(query qry: Insert(a)) -> Insert(a) {
  Insert(..qry, returning: NoReturning)
}

pub fn comment(query qry: Insert(a), comment cmmnt: String) -> Insert(a) {
  let cmmnt = cmmnt |> string.trim
  case cmmnt {
    "" -> Insert(..qry, comment: NoComment)
    _ -> Insert(..qry, comment: Comment(cmmnt))
  }
}

pub fn no_comment(query qry: Insert(a)) -> Insert(a) {
  Insert(..qry, comment: NoComment)
}
