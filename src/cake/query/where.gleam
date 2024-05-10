import cake/internal/query.{type Fragment, type WherePart, type WhereValue}
import cake/param
import cake/query/comparison.{type Comparison}

pub fn col(name: String) -> WhereValue {
  name |> query.WhereColumn
}

pub fn bool(value: Bool) -> WhereValue {
  value |> param.bool |> query.WhereParam
}

pub fn float(value: Float) -> WhereValue {
  value |> param.float |> query.WhereParam
}

pub fn int(value: Int) -> WhereValue {
  value |> param.int |> query.WhereParam
}

pub fn string(value: String) -> WhereValue {
  value |> param.string |> query.WhereParam
}

pub fn and(parts: List(WherePart)) -> WherePart {
  parts |> query.AndWhere
}

pub fn or(parts: List(WherePart)) -> WherePart {
  parts |> query.OrWhere
}

pub fn not(part: WherePart) -> WherePart {
  part |> query.NotWhere
}

pub fn cond(
  value_a val_a: WhereValue,
  operator oprtr: Comparison,
  value_b val_b: WhereValue,
) -> WherePart {
  case oprtr {
    comparison.EQ -> eq(val_a, val_b)
    comparison.GT -> gt(val_a, val_b)
    comparison.GTE -> gte(val_a, val_b)
    comparison.LT -> lt(val_a, val_b)
    comparison.LTE -> lte(val_a, val_b)
  }
}

pub fn eq(value_a val_a: WhereValue, value_b val_b: WhereValue) -> WherePart {
  val_a |> query.WhereEqual(val_b)
}

pub fn lt(value_a val_a: WhereValue, value_b val_b: WhereValue) -> WherePart {
  val_a |> query.WhereLower(val_b)
}

pub fn lte(value_a val_a: WhereValue, value_b val_b: WhereValue) -> WherePart {
  val_a |> query.WhereLowerOrEqual(val_b)
}

pub fn gt(value_a val_a: WhereValue, value_b val_b: WhereValue) -> WherePart {
  val_a |> query.WhereGreater(val_b)
}

pub fn gte(value_a val_a: WhereValue, value_b val_b: WhereValue) -> WherePart {
  val_a |> query.WhereGreaterOrEqual(val_b)
}

pub fn in(value val: WhereValue, values vals: List(WhereValue)) -> WherePart {
  val |> query.WhereIn(vals)
}

pub fn is_bool(value val: WhereValue, bool b: Bool) -> WherePart {
  val |> query.WhereIsBool(b)
}

pub fn is_not(value val: WhereValue, bool b: Bool) -> WherePart {
  val |> query.WhereIsNotBool(b)
}

pub fn is_null(value val: WhereValue) -> WherePart {
  val |> query.WhereIsNull
}

pub fn is_not_null(value val: WhereValue) -> WherePart {
  val |> query.WhereIsNotNull
}

pub fn like(value val: WhereValue, pattern pttrn: String) -> WherePart {
  val |> query.WhereLike(pttrn)
}

pub fn ilike(value val: WhereValue, pattern pttrn: String) -> WherePart {
  val |> query.WhereILike(pttrn)
}

pub fn fragment(fragment frgmt: Fragment) -> WhereValue {
  frgmt |> query.WhereFragments([])
}

pub fn fragments(
  fragment frgmt: Fragment,
  fragments frgmts: List(Fragment),
) -> WhereValue {
  query.WhereFragments(frgmt, frgmts)
}