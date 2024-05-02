/* tslint:disable */
/* eslint-disable */

export type ValueTypes = {
    /** columns and relationships of "associations" */
["associations"]: AliasType<{
	id?:true,
metadata?: [{	/** JSON select path */
	path?:string},true],
	ref_one_id?:true,
	ref_one_table?:true,
	ref_two_id?:true,
	ref_two_table?:true,
		__typename?: true
}>;
	/** aggregated selection of "associations" */
["associations_aggregate"]: AliasType<{
	aggregate?:ValueTypes["associations_aggregate_fields"],
	nodes?:ValueTypes["associations"],
		__typename?: true
}>;
	/** aggregate fields of "associations" */
["associations_aggregate_fields"]: AliasType<{
	avg?:ValueTypes["associations_avg_fields"],
count?: [{	columns?:ValueTypes["associations_select_column"][],	distinct?:boolean},true],
	max?:ValueTypes["associations_max_fields"],
	min?:ValueTypes["associations_min_fields"],
	stddev?:ValueTypes["associations_stddev_fields"],
	stddev_pop?:ValueTypes["associations_stddev_pop_fields"],
	stddev_samp?:ValueTypes["associations_stddev_samp_fields"],
	sum?:ValueTypes["associations_sum_fields"],
	var_pop?:ValueTypes["associations_var_pop_fields"],
	var_samp?:ValueTypes["associations_var_samp_fields"],
	variance?:ValueTypes["associations_variance_fields"],
		__typename?: true
}>;
	/** order by aggregate values of table "associations" */
["associations_aggregate_order_by"]: {
	avg?:ValueTypes["associations_avg_order_by"],
	count?:ValueTypes["order_by"],
	max?:ValueTypes["associations_max_order_by"],
	min?:ValueTypes["associations_min_order_by"],
	stddev?:ValueTypes["associations_stddev_order_by"],
	stddev_pop?:ValueTypes["associations_stddev_pop_order_by"],
	stddev_samp?:ValueTypes["associations_stddev_samp_order_by"],
	sum?:ValueTypes["associations_sum_order_by"],
	var_pop?:ValueTypes["associations_var_pop_order_by"],
	var_samp?:ValueTypes["associations_var_samp_order_by"],
	variance?:ValueTypes["associations_variance_order_by"]
};
	/** append existing jsonb value of filtered columns with new jsonb value */
["associations_append_input"]: {
	metadata?:ValueTypes["jsonb"]
};
	/** aggregate avg on columns */
["associations_avg_fields"]: AliasType<{
	id?:true,
	ref_one_id?:true,
	ref_two_id?:true,
		__typename?: true
}>;
	/** order by avg() on columns of table "associations" */
["associations_avg_order_by"]: {
	id?:ValueTypes["order_by"],
	ref_one_id?:ValueTypes["order_by"],
	ref_two_id?:ValueTypes["order_by"]
};
	/** Boolean expression to filter rows from the table "associations". All fields are combined with a logical 'AND'. */
["associations_bool_exp"]: {
	_and?:ValueTypes["associations_bool_exp"][],
	_not?:ValueTypes["associations_bool_exp"],
	_or?:ValueTypes["associations_bool_exp"][],
	id?:ValueTypes["Int_comparison_exp"],
	metadata?:ValueTypes["jsonb_comparison_exp"],
	ref_one_id?:ValueTypes["Int_comparison_exp"],
	ref_one_table?:ValueTypes["String_comparison_exp"],
	ref_two_id?:ValueTypes["Int_comparison_exp"],
	ref_two_table?:ValueTypes["String_comparison_exp"]
};
	/** unique or primary key constraints on table "associations" */
["associations_constraint"]:associations_constraint;
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
["associations_delete_at_path_input"]: {
	metadata?:string[]
};
	/** delete the array element with specified index (negative integers count from the
end). throws an error if top level container is not an array */
["associations_delete_elem_input"]: {
	metadata?:number
};
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
["associations_delete_key_input"]: {
	metadata?:string
};
	/** input type for incrementing numeric columns in table "associations" */
["associations_inc_input"]: {
	id?:number,
	ref_one_id?:number,
	ref_two_id?:number
};
	/** input type for inserting data into table "associations" */
["associations_insert_input"]: {
	id?:number,
	metadata?:ValueTypes["jsonb"],
	ref_one_id?:number,
	ref_one_table?:string,
	ref_two_id?:number,
	ref_two_table?:string
};
	/** aggregate max on columns */
["associations_max_fields"]: AliasType<{
	id?:true,
	ref_one_id?:true,
	ref_one_table?:true,
	ref_two_id?:true,
	ref_two_table?:true,
		__typename?: true
}>;
	/** order by max() on columns of table "associations" */
["associations_max_order_by"]: {
	id?:ValueTypes["order_by"],
	ref_one_id?:ValueTypes["order_by"],
	ref_one_table?:ValueTypes["order_by"],
	ref_two_id?:ValueTypes["order_by"],
	ref_two_table?:ValueTypes["order_by"]
};
	/** aggregate min on columns */
["associations_min_fields"]: AliasType<{
	id?:true,
	ref_one_id?:true,
	ref_one_table?:true,
	ref_two_id?:true,
	ref_two_table?:true,
		__typename?: true
}>;
	/** order by min() on columns of table "associations" */
["associations_min_order_by"]: {
	id?:ValueTypes["order_by"],
	ref_one_id?:ValueTypes["order_by"],
	ref_one_table?:ValueTypes["order_by"],
	ref_two_id?:ValueTypes["order_by"],
	ref_two_table?:ValueTypes["order_by"]
};
	/** response of any mutation on the table "associations" */
["associations_mutation_response"]: AliasType<{
	/** number of rows affected by the mutation */
	affected_rows?:true,
	/** data from the rows affected by the mutation */
	returning?:ValueTypes["associations"],
		__typename?: true
}>;
	/** on_conflict condition type for table "associations" */
["associations_on_conflict"]: {
	constraint:ValueTypes["associations_constraint"],
	update_columns:ValueTypes["associations_update_column"][],
	where?:ValueTypes["associations_bool_exp"]
};
	/** Ordering options when selecting data from "associations". */
["associations_order_by"]: {
	id?:ValueTypes["order_by"],
	metadata?:ValueTypes["order_by"],
	ref_one_id?:ValueTypes["order_by"],
	ref_one_table?:ValueTypes["order_by"],
	ref_two_id?:ValueTypes["order_by"],
	ref_two_table?:ValueTypes["order_by"]
};
	/** primary key columns input for table: associations */
["associations_pk_columns_input"]: {
	id:number
};
	/** prepend existing jsonb value of filtered columns with new jsonb value */
["associations_prepend_input"]: {
	metadata?:ValueTypes["jsonb"]
};
	/** select columns of table "associations" */
["associations_select_column"]:associations_select_column;
	/** input type for updating data in table "associations" */
["associations_set_input"]: {
	id?:number,
	metadata?:ValueTypes["jsonb"],
	ref_one_id?:number,
	ref_one_table?:string,
	ref_two_id?:number,
	ref_two_table?:string
};
	/** aggregate stddev on columns */
["associations_stddev_fields"]: AliasType<{
	id?:true,
	ref_one_id?:true,
	ref_two_id?:true,
		__typename?: true
}>;
	/** order by stddev() on columns of table "associations" */
["associations_stddev_order_by"]: {
	id?:ValueTypes["order_by"],
	ref_one_id?:ValueTypes["order_by"],
	ref_two_id?:ValueTypes["order_by"]
};
	/** aggregate stddev_pop on columns */
["associations_stddev_pop_fields"]: AliasType<{
	id?:true,
	ref_one_id?:true,
	ref_two_id?:true,
		__typename?: true
}>;
	/** order by stddev_pop() on columns of table "associations" */
["associations_stddev_pop_order_by"]: {
	id?:ValueTypes["order_by"],
	ref_one_id?:ValueTypes["order_by"],
	ref_two_id?:ValueTypes["order_by"]
};
	/** aggregate stddev_samp on columns */
["associations_stddev_samp_fields"]: AliasType<{
	id?:true,
	ref_one_id?:true,
	ref_two_id?:true,
		__typename?: true
}>;
	/** order by stddev_samp() on columns of table "associations" */
["associations_stddev_samp_order_by"]: {
	id?:ValueTypes["order_by"],
	ref_one_id?:ValueTypes["order_by"],
	ref_two_id?:ValueTypes["order_by"]
};
	/** Streaming cursor of the table "associations" */
["associations_stream_cursor_input"]: {
	/** Stream column input with initial value */
	initial_value:ValueTypes["associations_stream_cursor_value_input"],
	/** cursor ordering */
	ordering?:ValueTypes["cursor_ordering"]
};
	/** Initial value of the column from where the streaming should start */
["associations_stream_cursor_value_input"]: {
	id?:number,
	metadata?:ValueTypes["jsonb"],
	ref_one_id?:number,
	ref_one_table?:string,
	ref_two_id?:number,
	ref_two_table?:string
};
	/** aggregate sum on columns */
["associations_sum_fields"]: AliasType<{
	id?:true,
	ref_one_id?:true,
	ref_two_id?:true,
		__typename?: true
}>;
	/** order by sum() on columns of table "associations" */
["associations_sum_order_by"]: {
	id?:ValueTypes["order_by"],
	ref_one_id?:ValueTypes["order_by"],
	ref_two_id?:ValueTypes["order_by"]
};
	/** update columns of table "associations" */
["associations_update_column"]:associations_update_column;
	["associations_updates"]: {
	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:ValueTypes["associations_append_input"],
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:ValueTypes["associations_delete_at_path_input"],
	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:ValueTypes["associations_delete_elem_input"],
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:ValueTypes["associations_delete_key_input"],
	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["associations_inc_input"],
	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:ValueTypes["associations_prepend_input"],
	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["associations_set_input"],
	/** filter the rows which have to be updated */
	where:ValueTypes["associations_bool_exp"]
};
	/** aggregate var_pop on columns */
["associations_var_pop_fields"]: AliasType<{
	id?:true,
	ref_one_id?:true,
	ref_two_id?:true,
		__typename?: true
}>;
	/** order by var_pop() on columns of table "associations" */
["associations_var_pop_order_by"]: {
	id?:ValueTypes["order_by"],
	ref_one_id?:ValueTypes["order_by"],
	ref_two_id?:ValueTypes["order_by"]
};
	/** aggregate var_samp on columns */
["associations_var_samp_fields"]: AliasType<{
	id?:true,
	ref_one_id?:true,
	ref_two_id?:true,
		__typename?: true
}>;
	/** order by var_samp() on columns of table "associations" */
["associations_var_samp_order_by"]: {
	id?:ValueTypes["order_by"],
	ref_one_id?:ValueTypes["order_by"],
	ref_two_id?:ValueTypes["order_by"]
};
	/** aggregate variance on columns */
["associations_variance_fields"]: AliasType<{
	id?:true,
	ref_one_id?:true,
	ref_two_id?:true,
		__typename?: true
}>;
	/** order by variance() on columns of table "associations" */
["associations_variance_order_by"]: {
	id?:ValueTypes["order_by"],
	ref_one_id?:ValueTypes["order_by"],
	ref_two_id?:ValueTypes["order_by"]
};
	/** Boolean expression to compare columns of type "Boolean". All fields are combined with logical 'AND'. */
["Boolean_comparison_exp"]: {
	_eq?:boolean,
	_gt?:boolean,
	_gte?:boolean,
	_in?:boolean[],
	_is_null?:boolean,
	_lt?:boolean,
	_lte?:boolean,
	_neq?:boolean,
	_nin?:boolean[]
};
	["closest_user_location_args"]: {
	radius?:ValueTypes["float8"],
	ref_point?:string,
	user_row?:ValueTypes["users_scalar"]
};
	["closest_user_location_users_args"]: {
	radius?:ValueTypes["float8"],
	ref_point?:string
};
	/** ordering argument of a cursor */
["cursor_ordering"]:cursor_ordering;
	/** columns and relationships of "event_tag" */
["event_tag"]: AliasType<{
	/** An object relationship */
	event?:ValueTypes["events"],
	event_id?:true,
	tag_name?:true,
		__typename?: true
}>;
	/** aggregated selection of "event_tag" */
["event_tag_aggregate"]: AliasType<{
	aggregate?:ValueTypes["event_tag_aggregate_fields"],
	nodes?:ValueTypes["event_tag"],
		__typename?: true
}>;
	["event_tag_aggregate_bool_exp"]: {
	count?:ValueTypes["event_tag_aggregate_bool_exp_count"]
};
	["event_tag_aggregate_bool_exp_count"]: {
	arguments?:ValueTypes["event_tag_select_column"][],
	distinct?:boolean,
	filter?:ValueTypes["event_tag_bool_exp"],
	predicate:ValueTypes["Int_comparison_exp"]
};
	/** aggregate fields of "event_tag" */
["event_tag_aggregate_fields"]: AliasType<{
	avg?:ValueTypes["event_tag_avg_fields"],
count?: [{	columns?:ValueTypes["event_tag_select_column"][],	distinct?:boolean},true],
	max?:ValueTypes["event_tag_max_fields"],
	min?:ValueTypes["event_tag_min_fields"],
	stddev?:ValueTypes["event_tag_stddev_fields"],
	stddev_pop?:ValueTypes["event_tag_stddev_pop_fields"],
	stddev_samp?:ValueTypes["event_tag_stddev_samp_fields"],
	sum?:ValueTypes["event_tag_sum_fields"],
	var_pop?:ValueTypes["event_tag_var_pop_fields"],
	var_samp?:ValueTypes["event_tag_var_samp_fields"],
	variance?:ValueTypes["event_tag_variance_fields"],
		__typename?: true
}>;
	/** order by aggregate values of table "event_tag" */
["event_tag_aggregate_order_by"]: {
	avg?:ValueTypes["event_tag_avg_order_by"],
	count?:ValueTypes["order_by"],
	max?:ValueTypes["event_tag_max_order_by"],
	min?:ValueTypes["event_tag_min_order_by"],
	stddev?:ValueTypes["event_tag_stddev_order_by"],
	stddev_pop?:ValueTypes["event_tag_stddev_pop_order_by"],
	stddev_samp?:ValueTypes["event_tag_stddev_samp_order_by"],
	sum?:ValueTypes["event_tag_sum_order_by"],
	var_pop?:ValueTypes["event_tag_var_pop_order_by"],
	var_samp?:ValueTypes["event_tag_var_samp_order_by"],
	variance?:ValueTypes["event_tag_variance_order_by"]
};
	/** input type for inserting array relation for remote table "event_tag" */
["event_tag_arr_rel_insert_input"]: {
	data:ValueTypes["event_tag_insert_input"][],
	/** upsert condition */
	on_conflict?:ValueTypes["event_tag_on_conflict"]
};
	/** aggregate avg on columns */
["event_tag_avg_fields"]: AliasType<{
	event_id?:true,
		__typename?: true
}>;
	/** order by avg() on columns of table "event_tag" */
["event_tag_avg_order_by"]: {
	event_id?:ValueTypes["order_by"]
};
	/** Boolean expression to filter rows from the table "event_tag". All fields are combined with a logical 'AND'. */
["event_tag_bool_exp"]: {
	_and?:ValueTypes["event_tag_bool_exp"][],
	_not?:ValueTypes["event_tag_bool_exp"],
	_or?:ValueTypes["event_tag_bool_exp"][],
	event?:ValueTypes["events_bool_exp"],
	event_id?:ValueTypes["Int_comparison_exp"],
	tag_name?:ValueTypes["String_comparison_exp"]
};
	/** unique or primary key constraints on table "event_tag" */
["event_tag_constraint"]:event_tag_constraint;
	/** input type for incrementing numeric columns in table "event_tag" */
["event_tag_inc_input"]: {
	event_id?:number
};
	/** input type for inserting data into table "event_tag" */
["event_tag_insert_input"]: {
	event?:ValueTypes["events_obj_rel_insert_input"],
	event_id?:number,
	tag_name?:string
};
	/** aggregate max on columns */
["event_tag_max_fields"]: AliasType<{
	event_id?:true,
	tag_name?:true,
		__typename?: true
}>;
	/** order by max() on columns of table "event_tag" */
["event_tag_max_order_by"]: {
	event_id?:ValueTypes["order_by"],
	tag_name?:ValueTypes["order_by"]
};
	/** aggregate min on columns */
["event_tag_min_fields"]: AliasType<{
	event_id?:true,
	tag_name?:true,
		__typename?: true
}>;
	/** order by min() on columns of table "event_tag" */
["event_tag_min_order_by"]: {
	event_id?:ValueTypes["order_by"],
	tag_name?:ValueTypes["order_by"]
};
	/** response of any mutation on the table "event_tag" */
["event_tag_mutation_response"]: AliasType<{
	/** number of rows affected by the mutation */
	affected_rows?:true,
	/** data from the rows affected by the mutation */
	returning?:ValueTypes["event_tag"],
		__typename?: true
}>;
	/** on_conflict condition type for table "event_tag" */
["event_tag_on_conflict"]: {
	constraint:ValueTypes["event_tag_constraint"],
	update_columns:ValueTypes["event_tag_update_column"][],
	where?:ValueTypes["event_tag_bool_exp"]
};
	/** Ordering options when selecting data from "event_tag". */
["event_tag_order_by"]: {
	event?:ValueTypes["events_order_by"],
	event_id?:ValueTypes["order_by"],
	tag_name?:ValueTypes["order_by"]
};
	/** primary key columns input for table: event_tag */
["event_tag_pk_columns_input"]: {
	event_id:number,
	tag_name:string
};
	/** select columns of table "event_tag" */
["event_tag_select_column"]:event_tag_select_column;
	/** input type for updating data in table "event_tag" */
["event_tag_set_input"]: {
	event_id?:number,
	tag_name?:string
};
	/** aggregate stddev on columns */
["event_tag_stddev_fields"]: AliasType<{
	event_id?:true,
		__typename?: true
}>;
	/** order by stddev() on columns of table "event_tag" */
["event_tag_stddev_order_by"]: {
	event_id?:ValueTypes["order_by"]
};
	/** aggregate stddev_pop on columns */
["event_tag_stddev_pop_fields"]: AliasType<{
	event_id?:true,
		__typename?: true
}>;
	/** order by stddev_pop() on columns of table "event_tag" */
["event_tag_stddev_pop_order_by"]: {
	event_id?:ValueTypes["order_by"]
};
	/** aggregate stddev_samp on columns */
["event_tag_stddev_samp_fields"]: AliasType<{
	event_id?:true,
		__typename?: true
}>;
	/** order by stddev_samp() on columns of table "event_tag" */
["event_tag_stddev_samp_order_by"]: {
	event_id?:ValueTypes["order_by"]
};
	/** Streaming cursor of the table "event_tag" */
["event_tag_stream_cursor_input"]: {
	/** Stream column input with initial value */
	initial_value:ValueTypes["event_tag_stream_cursor_value_input"],
	/** cursor ordering */
	ordering?:ValueTypes["cursor_ordering"]
};
	/** Initial value of the column from where the streaming should start */
["event_tag_stream_cursor_value_input"]: {
	event_id?:number,
	tag_name?:string
};
	/** aggregate sum on columns */
["event_tag_sum_fields"]: AliasType<{
	event_id?:true,
		__typename?: true
}>;
	/** order by sum() on columns of table "event_tag" */
["event_tag_sum_order_by"]: {
	event_id?:ValueTypes["order_by"]
};
	/** update columns of table "event_tag" */
["event_tag_update_column"]:event_tag_update_column;
	["event_tag_updates"]: {
	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["event_tag_inc_input"],
	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["event_tag_set_input"],
	/** filter the rows which have to be updated */
	where:ValueTypes["event_tag_bool_exp"]
};
	/** aggregate var_pop on columns */
["event_tag_var_pop_fields"]: AliasType<{
	event_id?:true,
		__typename?: true
}>;
	/** order by var_pop() on columns of table "event_tag" */
["event_tag_var_pop_order_by"]: {
	event_id?:ValueTypes["order_by"]
};
	/** aggregate var_samp on columns */
["event_tag_var_samp_fields"]: AliasType<{
	event_id?:true,
		__typename?: true
}>;
	/** order by var_samp() on columns of table "event_tag" */
["event_tag_var_samp_order_by"]: {
	event_id?:ValueTypes["order_by"]
};
	/** aggregate variance on columns */
["event_tag_variance_fields"]: AliasType<{
	event_id?:true,
		__typename?: true
}>;
	/** order by variance() on columns of table "event_tag" */
["event_tag_variance_order_by"]: {
	event_id?:ValueTypes["order_by"]
};
	/** columns and relationships of "event_types" */
["event_types"]: AliasType<{
children?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["event_types_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["event_types_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["event_types_bool_exp"]},ValueTypes["event_types"]],
children_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["event_types_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["event_types_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["event_types_bool_exp"]},ValueTypes["event_types_aggregate"]],
	embedding?:true,
metadata?: [{	/** JSON select path */
	path?:string},true],
	name?:true,
	parent?:true,
	/** A computed field, executes function "get_event_type_path" */
	parent_tree?:true,
		__typename?: true
}>;
	/** aggregated selection of "event_types" */
["event_types_aggregate"]: AliasType<{
	aggregate?:ValueTypes["event_types_aggregate_fields"],
	nodes?:ValueTypes["event_types"],
		__typename?: true
}>;
	["event_types_aggregate_bool_exp"]: {
	count?:ValueTypes["event_types_aggregate_bool_exp_count"]
};
	["event_types_aggregate_bool_exp_count"]: {
	arguments?:ValueTypes["event_types_select_column"][],
	distinct?:boolean,
	filter?:ValueTypes["event_types_bool_exp"],
	predicate:ValueTypes["Int_comparison_exp"]
};
	/** aggregate fields of "event_types" */
["event_types_aggregate_fields"]: AliasType<{
count?: [{	columns?:ValueTypes["event_types_select_column"][],	distinct?:boolean},true],
	max?:ValueTypes["event_types_max_fields"],
	min?:ValueTypes["event_types_min_fields"],
		__typename?: true
}>;
	/** order by aggregate values of table "event_types" */
["event_types_aggregate_order_by"]: {
	count?:ValueTypes["order_by"],
	max?:ValueTypes["event_types_max_order_by"],
	min?:ValueTypes["event_types_min_order_by"]
};
	/** append existing jsonb value of filtered columns with new jsonb value */
["event_types_append_input"]: {
	metadata?:ValueTypes["jsonb"]
};
	/** input type for inserting array relation for remote table "event_types" */
["event_types_arr_rel_insert_input"]: {
	data:ValueTypes["event_types_insert_input"][],
	/** upsert condition */
	on_conflict?:ValueTypes["event_types_on_conflict"]
};
	/** Boolean expression to filter rows from the table "event_types". All fields are combined with a logical 'AND'. */
["event_types_bool_exp"]: {
	_and?:ValueTypes["event_types_bool_exp"][],
	_not?:ValueTypes["event_types_bool_exp"],
	_or?:ValueTypes["event_types_bool_exp"][],
	children?:ValueTypes["event_types_bool_exp"],
	children_aggregate?:ValueTypes["event_types_aggregate_bool_exp"],
	embedding?:ValueTypes["vector_comparison_exp"],
	metadata?:ValueTypes["jsonb_comparison_exp"],
	name?:ValueTypes["String_comparison_exp"],
	parent?:ValueTypes["String_comparison_exp"],
	parent_tree?:ValueTypes["String_comparison_exp"]
};
	/** unique or primary key constraints on table "event_types" */
["event_types_constraint"]:event_types_constraint;
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
["event_types_delete_at_path_input"]: {
	metadata?:string[]
};
	/** delete the array element with specified index (negative integers count from the
end). throws an error if top level container is not an array */
["event_types_delete_elem_input"]: {
	metadata?:number
};
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
["event_types_delete_key_input"]: {
	metadata?:string
};
	/** input type for inserting data into table "event_types" */
["event_types_insert_input"]: {
	children?:ValueTypes["event_types_arr_rel_insert_input"],
	embedding?:ValueTypes["vector"],
	metadata?:ValueTypes["jsonb"],
	name?:string,
	parent?:string
};
	/** aggregate max on columns */
["event_types_max_fields"]: AliasType<{
	name?:true,
	parent?:true,
	/** A computed field, executes function "get_event_type_path" */
	parent_tree?:true,
		__typename?: true
}>;
	/** order by max() on columns of table "event_types" */
["event_types_max_order_by"]: {
	name?:ValueTypes["order_by"],
	parent?:ValueTypes["order_by"]
};
	/** aggregate min on columns */
["event_types_min_fields"]: AliasType<{
	name?:true,
	parent?:true,
	/** A computed field, executes function "get_event_type_path" */
	parent_tree?:true,
		__typename?: true
}>;
	/** order by min() on columns of table "event_types" */
["event_types_min_order_by"]: {
	name?:ValueTypes["order_by"],
	parent?:ValueTypes["order_by"]
};
	/** response of any mutation on the table "event_types" */
["event_types_mutation_response"]: AliasType<{
	/** number of rows affected by the mutation */
	affected_rows?:true,
	/** data from the rows affected by the mutation */
	returning?:ValueTypes["event_types"],
		__typename?: true
}>;
	/** input type for inserting object relation for remote table "event_types" */
["event_types_obj_rel_insert_input"]: {
	data:ValueTypes["event_types_insert_input"],
	/** upsert condition */
	on_conflict?:ValueTypes["event_types_on_conflict"]
};
	/** on_conflict condition type for table "event_types" */
["event_types_on_conflict"]: {
	constraint:ValueTypes["event_types_constraint"],
	update_columns:ValueTypes["event_types_update_column"][],
	where?:ValueTypes["event_types_bool_exp"]
};
	/** Ordering options when selecting data from "event_types". */
["event_types_order_by"]: {
	children_aggregate?:ValueTypes["event_types_aggregate_order_by"],
	embedding?:ValueTypes["order_by"],
	metadata?:ValueTypes["order_by"],
	name?:ValueTypes["order_by"],
	parent?:ValueTypes["order_by"],
	parent_tree?:ValueTypes["order_by"]
};
	/** primary key columns input for table: event_types */
["event_types_pk_columns_input"]: {
	name:string
};
	/** prepend existing jsonb value of filtered columns with new jsonb value */
["event_types_prepend_input"]: {
	metadata?:ValueTypes["jsonb"]
};
	/** select columns of table "event_types" */
["event_types_select_column"]:event_types_select_column;
	/** input type for updating data in table "event_types" */
["event_types_set_input"]: {
	embedding?:ValueTypes["vector"],
	metadata?:ValueTypes["jsonb"],
	name?:string,
	parent?:string
};
	/** Streaming cursor of the table "event_types" */
["event_types_stream_cursor_input"]: {
	/** Stream column input with initial value */
	initial_value:ValueTypes["event_types_stream_cursor_value_input"],
	/** cursor ordering */
	ordering?:ValueTypes["cursor_ordering"]
};
	/** Initial value of the column from where the streaming should start */
["event_types_stream_cursor_value_input"]: {
	embedding?:ValueTypes["vector"],
	metadata?:ValueTypes["jsonb"],
	name?:string,
	parent?:string
};
	/** update columns of table "event_types" */
["event_types_update_column"]:event_types_update_column;
	["event_types_updates"]: {
	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:ValueTypes["event_types_append_input"],
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:ValueTypes["event_types_delete_at_path_input"],
	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:ValueTypes["event_types_delete_elem_input"],
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:ValueTypes["event_types_delete_key_input"],
	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:ValueTypes["event_types_prepend_input"],
	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["event_types_set_input"],
	/** filter the rows which have to be updated */
	where:ValueTypes["event_types_bool_exp"]
};
	/** columns and relationships of "events" */
["events"]: AliasType<{
associations?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["associations_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["associations_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["associations_bool_exp"]},ValueTypes["associations"]],
children?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["events_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["events_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["events_bool_exp"]},ValueTypes["events"]],
children_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["events_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["events_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["events_bool_exp"]},ValueTypes["events_aggregate"]],
	/** A computed field, executes function "event_duration" */
	computed_cost_time?:true,
	/** cents */
	cost_money?:true,
	/** seconds */
	cost_time?:true,
	end_time?:true,
event_tags?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["event_tag_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["event_tag_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["event_tag_bool_exp"]},ValueTypes["event_tag"]],
event_tags_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["event_tag_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["event_tag_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["event_tag_bool_exp"]},ValueTypes["event_tag_aggregate"]],
	event_type?:true,
	/** An object relationship */
	event_type_object?:ValueTypes["event_types"],
	goal_id?:true,
	id?:true,
	/** An object relationship */
	interaction?:ValueTypes["interactions"],
	interaction_id?:true,
logs?: [{	/** JSON select path */
	path?:string},true],
metadata?: [{	/** JSON select path */
	path?:string},true],
	/** An object relationship */
	parent?:ValueTypes["events"],
	parent_id?:true,
	start_time?:true,
	status?:true,
	/** An object relationship */
	user?:ValueTypes["users"],
	user_id?:true,
		__typename?: true
}>;
	/** aggregated selection of "events" */
["events_aggregate"]: AliasType<{
	aggregate?:ValueTypes["events_aggregate_fields"],
	nodes?:ValueTypes["events"],
		__typename?: true
}>;
	["events_aggregate_bool_exp"]: {
	count?:ValueTypes["events_aggregate_bool_exp_count"]
};
	["events_aggregate_bool_exp_count"]: {
	arguments?:ValueTypes["events_select_column"][],
	distinct?:boolean,
	filter?:ValueTypes["events_bool_exp"],
	predicate:ValueTypes["Int_comparison_exp"]
};
	/** aggregate fields of "events" */
["events_aggregate_fields"]: AliasType<{
	avg?:ValueTypes["events_avg_fields"],
count?: [{	columns?:ValueTypes["events_select_column"][],	distinct?:boolean},true],
	max?:ValueTypes["events_max_fields"],
	min?:ValueTypes["events_min_fields"],
	stddev?:ValueTypes["events_stddev_fields"],
	stddev_pop?:ValueTypes["events_stddev_pop_fields"],
	stddev_samp?:ValueTypes["events_stddev_samp_fields"],
	sum?:ValueTypes["events_sum_fields"],
	var_pop?:ValueTypes["events_var_pop_fields"],
	var_samp?:ValueTypes["events_var_samp_fields"],
	variance?:ValueTypes["events_variance_fields"],
		__typename?: true
}>;
	/** order by aggregate values of table "events" */
["events_aggregate_order_by"]: {
	avg?:ValueTypes["events_avg_order_by"],
	count?:ValueTypes["order_by"],
	max?:ValueTypes["events_max_order_by"],
	min?:ValueTypes["events_min_order_by"],
	stddev?:ValueTypes["events_stddev_order_by"],
	stddev_pop?:ValueTypes["events_stddev_pop_order_by"],
	stddev_samp?:ValueTypes["events_stddev_samp_order_by"],
	sum?:ValueTypes["events_sum_order_by"],
	var_pop?:ValueTypes["events_var_pop_order_by"],
	var_samp?:ValueTypes["events_var_samp_order_by"],
	variance?:ValueTypes["events_variance_order_by"]
};
	/** append existing jsonb value of filtered columns with new jsonb value */
["events_append_input"]: {
	logs?:ValueTypes["jsonb"],
	metadata?:ValueTypes["jsonb"]
};
	/** input type for inserting array relation for remote table "events" */
["events_arr_rel_insert_input"]: {
	data:ValueTypes["events_insert_input"][],
	/** upsert condition */
	on_conflict?:ValueTypes["events_on_conflict"]
};
	/** aggregate avg on columns */
["events_avg_fields"]: AliasType<{
	/** A computed field, executes function "event_duration" */
	computed_cost_time?:true,
	/** cents */
	cost_money?:true,
	/** seconds */
	cost_time?:true,
	goal_id?:true,
	id?:true,
	interaction_id?:true,
	parent_id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** order by avg() on columns of table "events" */
["events_avg_order_by"]: {
	/** cents */
	cost_money?:ValueTypes["order_by"],
	/** seconds */
	cost_time?:ValueTypes["order_by"],
	goal_id?:ValueTypes["order_by"],
	id?:ValueTypes["order_by"],
	interaction_id?:ValueTypes["order_by"],
	parent_id?:ValueTypes["order_by"],
	user_id?:ValueTypes["order_by"]
};
	/** Boolean expression to filter rows from the table "events". All fields are combined with a logical 'AND'. */
["events_bool_exp"]: {
	_and?:ValueTypes["events_bool_exp"][],
	_not?:ValueTypes["events_bool_exp"],
	_or?:ValueTypes["events_bool_exp"][],
	associations?:ValueTypes["associations_bool_exp"],
	children?:ValueTypes["events_bool_exp"],
	children_aggregate?:ValueTypes["events_aggregate_bool_exp"],
	computed_cost_time?:ValueTypes["Int_comparison_exp"],
	cost_money?:ValueTypes["Int_comparison_exp"],
	cost_time?:ValueTypes["Int_comparison_exp"],
	end_time?:ValueTypes["timestamp_comparison_exp"],
	event_tags?:ValueTypes["event_tag_bool_exp"],
	event_tags_aggregate?:ValueTypes["event_tag_aggregate_bool_exp"],
	event_type?:ValueTypes["String_comparison_exp"],
	event_type_object?:ValueTypes["event_types_bool_exp"],
	goal_id?:ValueTypes["Int_comparison_exp"],
	id?:ValueTypes["Int_comparison_exp"],
	interaction?:ValueTypes["interactions_bool_exp"],
	interaction_id?:ValueTypes["Int_comparison_exp"],
	logs?:ValueTypes["jsonb_comparison_exp"],
	metadata?:ValueTypes["jsonb_comparison_exp"],
	parent?:ValueTypes["events_bool_exp"],
	parent_id?:ValueTypes["Int_comparison_exp"],
	start_time?:ValueTypes["timestamp_comparison_exp"],
	status?:ValueTypes["String_comparison_exp"],
	user?:ValueTypes["users_bool_exp"],
	user_id?:ValueTypes["Int_comparison_exp"]
};
	/** unique or primary key constraints on table "events" */
["events_constraint"]:events_constraint;
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
["events_delete_at_path_input"]: {
	logs?:string[],
	metadata?:string[]
};
	/** delete the array element with specified index (negative integers count from the
end). throws an error if top level container is not an array */
["events_delete_elem_input"]: {
	logs?:number,
	metadata?:number
};
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
["events_delete_key_input"]: {
	logs?:string,
	metadata?:string
};
	/** input type for incrementing numeric columns in table "events" */
["events_inc_input"]: {
	/** cents */
	cost_money?:number,
	/** seconds */
	cost_time?:number,
	goal_id?:number,
	id?:number,
	interaction_id?:number,
	parent_id?:number,
	user_id?:number
};
	/** input type for inserting data into table "events" */
["events_insert_input"]: {
	children?:ValueTypes["events_arr_rel_insert_input"],
	/** cents */
	cost_money?:number,
	/** seconds */
	cost_time?:number,
	end_time?:ValueTypes["timestamp"],
	event_tags?:ValueTypes["event_tag_arr_rel_insert_input"],
	event_type?:string,
	event_type_object?:ValueTypes["event_types_obj_rel_insert_input"],
	goal_id?:number,
	id?:number,
	interaction?:ValueTypes["interactions_obj_rel_insert_input"],
	interaction_id?:number,
	logs?:ValueTypes["jsonb"],
	metadata?:ValueTypes["jsonb"],
	parent?:ValueTypes["events_obj_rel_insert_input"],
	parent_id?:number,
	start_time?:ValueTypes["timestamp"],
	status?:string,
	user?:ValueTypes["users_obj_rel_insert_input"],
	user_id?:number
};
	/** aggregate max on columns */
["events_max_fields"]: AliasType<{
	/** A computed field, executes function "event_duration" */
	computed_cost_time?:true,
	/** cents */
	cost_money?:true,
	/** seconds */
	cost_time?:true,
	end_time?:true,
	event_type?:true,
	goal_id?:true,
	id?:true,
	interaction_id?:true,
	parent_id?:true,
	start_time?:true,
	status?:true,
	user_id?:true,
		__typename?: true
}>;
	/** order by max() on columns of table "events" */
["events_max_order_by"]: {
	/** cents */
	cost_money?:ValueTypes["order_by"],
	/** seconds */
	cost_time?:ValueTypes["order_by"],
	end_time?:ValueTypes["order_by"],
	event_type?:ValueTypes["order_by"],
	goal_id?:ValueTypes["order_by"],
	id?:ValueTypes["order_by"],
	interaction_id?:ValueTypes["order_by"],
	parent_id?:ValueTypes["order_by"],
	start_time?:ValueTypes["order_by"],
	status?:ValueTypes["order_by"],
	user_id?:ValueTypes["order_by"]
};
	/** aggregate min on columns */
["events_min_fields"]: AliasType<{
	/** A computed field, executes function "event_duration" */
	computed_cost_time?:true,
	/** cents */
	cost_money?:true,
	/** seconds */
	cost_time?:true,
	end_time?:true,
	event_type?:true,
	goal_id?:true,
	id?:true,
	interaction_id?:true,
	parent_id?:true,
	start_time?:true,
	status?:true,
	user_id?:true,
		__typename?: true
}>;
	/** order by min() on columns of table "events" */
["events_min_order_by"]: {
	/** cents */
	cost_money?:ValueTypes["order_by"],
	/** seconds */
	cost_time?:ValueTypes["order_by"],
	end_time?:ValueTypes["order_by"],
	event_type?:ValueTypes["order_by"],
	goal_id?:ValueTypes["order_by"],
	id?:ValueTypes["order_by"],
	interaction_id?:ValueTypes["order_by"],
	parent_id?:ValueTypes["order_by"],
	start_time?:ValueTypes["order_by"],
	status?:ValueTypes["order_by"],
	user_id?:ValueTypes["order_by"]
};
	/** response of any mutation on the table "events" */
["events_mutation_response"]: AliasType<{
	/** number of rows affected by the mutation */
	affected_rows?:true,
	/** data from the rows affected by the mutation */
	returning?:ValueTypes["events"],
		__typename?: true
}>;
	/** input type for inserting object relation for remote table "events" */
["events_obj_rel_insert_input"]: {
	data:ValueTypes["events_insert_input"],
	/** upsert condition */
	on_conflict?:ValueTypes["events_on_conflict"]
};
	/** on_conflict condition type for table "events" */
["events_on_conflict"]: {
	constraint:ValueTypes["events_constraint"],
	update_columns:ValueTypes["events_update_column"][],
	where?:ValueTypes["events_bool_exp"]
};
	/** Ordering options when selecting data from "events". */
["events_order_by"]: {
	associations_aggregate?:ValueTypes["associations_aggregate_order_by"],
	children_aggregate?:ValueTypes["events_aggregate_order_by"],
	computed_cost_time?:ValueTypes["order_by"],
	cost_money?:ValueTypes["order_by"],
	cost_time?:ValueTypes["order_by"],
	end_time?:ValueTypes["order_by"],
	event_tags_aggregate?:ValueTypes["event_tag_aggregate_order_by"],
	event_type?:ValueTypes["order_by"],
	event_type_object?:ValueTypes["event_types_order_by"],
	goal_id?:ValueTypes["order_by"],
	id?:ValueTypes["order_by"],
	interaction?:ValueTypes["interactions_order_by"],
	interaction_id?:ValueTypes["order_by"],
	logs?:ValueTypes["order_by"],
	metadata?:ValueTypes["order_by"],
	parent?:ValueTypes["events_order_by"],
	parent_id?:ValueTypes["order_by"],
	start_time?:ValueTypes["order_by"],
	status?:ValueTypes["order_by"],
	user?:ValueTypes["users_order_by"],
	user_id?:ValueTypes["order_by"]
};
	/** primary key columns input for table: events */
["events_pk_columns_input"]: {
	id:number
};
	/** prepend existing jsonb value of filtered columns with new jsonb value */
["events_prepend_input"]: {
	logs?:ValueTypes["jsonb"],
	metadata?:ValueTypes["jsonb"]
};
	/** select columns of table "events" */
["events_select_column"]:events_select_column;
	/** input type for updating data in table "events" */
["events_set_input"]: {
	/** cents */
	cost_money?:number,
	/** seconds */
	cost_time?:number,
	end_time?:ValueTypes["timestamp"],
	event_type?:string,
	goal_id?:number,
	id?:number,
	interaction_id?:number,
	logs?:ValueTypes["jsonb"],
	metadata?:ValueTypes["jsonb"],
	parent_id?:number,
	start_time?:ValueTypes["timestamp"],
	status?:string,
	user_id?:number
};
	/** aggregate stddev on columns */
["events_stddev_fields"]: AliasType<{
	/** A computed field, executes function "event_duration" */
	computed_cost_time?:true,
	/** cents */
	cost_money?:true,
	/** seconds */
	cost_time?:true,
	goal_id?:true,
	id?:true,
	interaction_id?:true,
	parent_id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** order by stddev() on columns of table "events" */
["events_stddev_order_by"]: {
	/** cents */
	cost_money?:ValueTypes["order_by"],
	/** seconds */
	cost_time?:ValueTypes["order_by"],
	goal_id?:ValueTypes["order_by"],
	id?:ValueTypes["order_by"],
	interaction_id?:ValueTypes["order_by"],
	parent_id?:ValueTypes["order_by"],
	user_id?:ValueTypes["order_by"]
};
	/** aggregate stddev_pop on columns */
["events_stddev_pop_fields"]: AliasType<{
	/** A computed field, executes function "event_duration" */
	computed_cost_time?:true,
	/** cents */
	cost_money?:true,
	/** seconds */
	cost_time?:true,
	goal_id?:true,
	id?:true,
	interaction_id?:true,
	parent_id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** order by stddev_pop() on columns of table "events" */
["events_stddev_pop_order_by"]: {
	/** cents */
	cost_money?:ValueTypes["order_by"],
	/** seconds */
	cost_time?:ValueTypes["order_by"],
	goal_id?:ValueTypes["order_by"],
	id?:ValueTypes["order_by"],
	interaction_id?:ValueTypes["order_by"],
	parent_id?:ValueTypes["order_by"],
	user_id?:ValueTypes["order_by"]
};
	/** aggregate stddev_samp on columns */
["events_stddev_samp_fields"]: AliasType<{
	/** A computed field, executes function "event_duration" */
	computed_cost_time?:true,
	/** cents */
	cost_money?:true,
	/** seconds */
	cost_time?:true,
	goal_id?:true,
	id?:true,
	interaction_id?:true,
	parent_id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** order by stddev_samp() on columns of table "events" */
["events_stddev_samp_order_by"]: {
	/** cents */
	cost_money?:ValueTypes["order_by"],
	/** seconds */
	cost_time?:ValueTypes["order_by"],
	goal_id?:ValueTypes["order_by"],
	id?:ValueTypes["order_by"],
	interaction_id?:ValueTypes["order_by"],
	parent_id?:ValueTypes["order_by"],
	user_id?:ValueTypes["order_by"]
};
	/** Streaming cursor of the table "events" */
["events_stream_cursor_input"]: {
	/** Stream column input with initial value */
	initial_value:ValueTypes["events_stream_cursor_value_input"],
	/** cursor ordering */
	ordering?:ValueTypes["cursor_ordering"]
};
	/** Initial value of the column from where the streaming should start */
["events_stream_cursor_value_input"]: {
	/** cents */
	cost_money?:number,
	/** seconds */
	cost_time?:number,
	end_time?:ValueTypes["timestamp"],
	event_type?:string,
	goal_id?:number,
	id?:number,
	interaction_id?:number,
	logs?:ValueTypes["jsonb"],
	metadata?:ValueTypes["jsonb"],
	parent_id?:number,
	start_time?:ValueTypes["timestamp"],
	status?:string,
	user_id?:number
};
	/** aggregate sum on columns */
["events_sum_fields"]: AliasType<{
	/** A computed field, executes function "event_duration" */
	computed_cost_time?:true,
	/** cents */
	cost_money?:true,
	/** seconds */
	cost_time?:true,
	goal_id?:true,
	id?:true,
	interaction_id?:true,
	parent_id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** order by sum() on columns of table "events" */
["events_sum_order_by"]: {
	/** cents */
	cost_money?:ValueTypes["order_by"],
	/** seconds */
	cost_time?:ValueTypes["order_by"],
	goal_id?:ValueTypes["order_by"],
	id?:ValueTypes["order_by"],
	interaction_id?:ValueTypes["order_by"],
	parent_id?:ValueTypes["order_by"],
	user_id?:ValueTypes["order_by"]
};
	/** update columns of table "events" */
["events_update_column"]:events_update_column;
	["events_updates"]: {
	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:ValueTypes["events_append_input"],
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:ValueTypes["events_delete_at_path_input"],
	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:ValueTypes["events_delete_elem_input"],
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:ValueTypes["events_delete_key_input"],
	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["events_inc_input"],
	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:ValueTypes["events_prepend_input"],
	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["events_set_input"],
	/** filter the rows which have to be updated */
	where:ValueTypes["events_bool_exp"]
};
	/** aggregate var_pop on columns */
["events_var_pop_fields"]: AliasType<{
	/** A computed field, executes function "event_duration" */
	computed_cost_time?:true,
	/** cents */
	cost_money?:true,
	/** seconds */
	cost_time?:true,
	goal_id?:true,
	id?:true,
	interaction_id?:true,
	parent_id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** order by var_pop() on columns of table "events" */
["events_var_pop_order_by"]: {
	/** cents */
	cost_money?:ValueTypes["order_by"],
	/** seconds */
	cost_time?:ValueTypes["order_by"],
	goal_id?:ValueTypes["order_by"],
	id?:ValueTypes["order_by"],
	interaction_id?:ValueTypes["order_by"],
	parent_id?:ValueTypes["order_by"],
	user_id?:ValueTypes["order_by"]
};
	/** aggregate var_samp on columns */
["events_var_samp_fields"]: AliasType<{
	/** A computed field, executes function "event_duration" */
	computed_cost_time?:true,
	/** cents */
	cost_money?:true,
	/** seconds */
	cost_time?:true,
	goal_id?:true,
	id?:true,
	interaction_id?:true,
	parent_id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** order by var_samp() on columns of table "events" */
["events_var_samp_order_by"]: {
	/** cents */
	cost_money?:ValueTypes["order_by"],
	/** seconds */
	cost_time?:ValueTypes["order_by"],
	goal_id?:ValueTypes["order_by"],
	id?:ValueTypes["order_by"],
	interaction_id?:ValueTypes["order_by"],
	parent_id?:ValueTypes["order_by"],
	user_id?:ValueTypes["order_by"]
};
	/** aggregate variance on columns */
["events_variance_fields"]: AliasType<{
	/** A computed field, executes function "event_duration" */
	computed_cost_time?:true,
	/** cents */
	cost_money?:true,
	/** seconds */
	cost_time?:true,
	goal_id?:true,
	id?:true,
	interaction_id?:true,
	parent_id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** order by variance() on columns of table "events" */
["events_variance_order_by"]: {
	/** cents */
	cost_money?:ValueTypes["order_by"],
	/** seconds */
	cost_time?:ValueTypes["order_by"],
	goal_id?:ValueTypes["order_by"],
	id?:ValueTypes["order_by"],
	interaction_id?:ValueTypes["order_by"],
	parent_id?:ValueTypes["order_by"],
	user_id?:ValueTypes["order_by"]
};
	["fetch_associations_args"]: {
	from_row_id?:number,
	from_row_type?:string
};
	["float8"]:unknown;
	/** Boolean expression to compare columns of type "float8". All fields are combined with logical 'AND'. */
["float8_comparison_exp"]: {
	_eq?:ValueTypes["float8"],
	_gt?:ValueTypes["float8"],
	_gte?:ValueTypes["float8"],
	_in?:ValueTypes["float8"][],
	_is_null?:boolean,
	_lt?:ValueTypes["float8"],
	_lte?:ValueTypes["float8"],
	_neq?:ValueTypes["float8"],
	_nin?:ValueTypes["float8"][]
};
	["geography"]:unknown;
	["geography_cast_exp"]: {
	geometry?:ValueTypes["geometry_comparison_exp"]
};
	/** Boolean expression to compare columns of type "geography". All fields are combined with logical 'AND'. */
["geography_comparison_exp"]: {
	_cast?:ValueTypes["geography_cast_exp"],
	_eq?:ValueTypes["geography"],
	_gt?:ValueTypes["geography"],
	_gte?:ValueTypes["geography"],
	_in?:ValueTypes["geography"][],
	_is_null?:boolean,
	_lt?:ValueTypes["geography"],
	_lte?:ValueTypes["geography"],
	_neq?:ValueTypes["geography"],
	_nin?:ValueTypes["geography"][],
	/** is the column within a given distance from the given geography value */
	_st_d_within?:ValueTypes["st_d_within_geography_input"],
	/** does the column spatially intersect the given geography value */
	_st_intersects?:ValueTypes["geography"]
};
	["geometry"]:unknown;
	["geometry_cast_exp"]: {
	geography?:ValueTypes["geography_comparison_exp"]
};
	/** Boolean expression to compare columns of type "geometry". All fields are combined with logical 'AND'. */
["geometry_comparison_exp"]: {
	_cast?:ValueTypes["geometry_cast_exp"],
	_eq?:ValueTypes["geometry"],
	_gt?:ValueTypes["geometry"],
	_gte?:ValueTypes["geometry"],
	_in?:ValueTypes["geometry"][],
	_is_null?:boolean,
	_lt?:ValueTypes["geometry"],
	_lte?:ValueTypes["geometry"],
	_neq?:ValueTypes["geometry"],
	_nin?:ValueTypes["geometry"][],
	/** is the column within a given 3D distance from the given geometry value */
	_st_3d_d_within?:ValueTypes["st_d_within_input"],
	/** does the column spatially intersect the given geometry value in 3D */
	_st_3d_intersects?:ValueTypes["geometry"],
	/** does the column contain the given geometry value */
	_st_contains?:ValueTypes["geometry"],
	/** does the column cross the given geometry value */
	_st_crosses?:ValueTypes["geometry"],
	/** is the column within a given distance from the given geometry value */
	_st_d_within?:ValueTypes["st_d_within_input"],
	/** is the column equal to given geometry value (directionality is ignored) */
	_st_equals?:ValueTypes["geometry"],
	/** does the column spatially intersect the given geometry value */
	_st_intersects?:ValueTypes["geometry"],
	/** does the column 'spatially overlap' (intersect but not completely contain) the given geometry value */
	_st_overlaps?:ValueTypes["geometry"],
	/** does the column have atleast one point in common with the given geometry value */
	_st_touches?:ValueTypes["geometry"],
	/** is the column contained in the given geometry value */
	_st_within?:ValueTypes["geometry"]
};
	/** columns and relationships of "goals" */
["goals"]: AliasType<{
	created?:true,
frequency?: [{	/** JSON select path */
	path?:string},true],
	id?:true,
	name?:true,
	nl_description?:true,
	status?:true,
	/** An object relationship */
	todo?:ValueTypes["todos"],
	/** An object relationship */
	user?:ValueTypes["users"],
	user_id?:true,
		__typename?: true
}>;
	/** aggregated selection of "goals" */
["goals_aggregate"]: AliasType<{
	aggregate?:ValueTypes["goals_aggregate_fields"],
	nodes?:ValueTypes["goals"],
		__typename?: true
}>;
	/** aggregate fields of "goals" */
["goals_aggregate_fields"]: AliasType<{
	avg?:ValueTypes["goals_avg_fields"],
count?: [{	columns?:ValueTypes["goals_select_column"][],	distinct?:boolean},true],
	max?:ValueTypes["goals_max_fields"],
	min?:ValueTypes["goals_min_fields"],
	stddev?:ValueTypes["goals_stddev_fields"],
	stddev_pop?:ValueTypes["goals_stddev_pop_fields"],
	stddev_samp?:ValueTypes["goals_stddev_samp_fields"],
	sum?:ValueTypes["goals_sum_fields"],
	var_pop?:ValueTypes["goals_var_pop_fields"],
	var_samp?:ValueTypes["goals_var_samp_fields"],
	variance?:ValueTypes["goals_variance_fields"],
		__typename?: true
}>;
	/** append existing jsonb value of filtered columns with new jsonb value */
["goals_append_input"]: {
	frequency?:ValueTypes["jsonb"]
};
	/** aggregate avg on columns */
["goals_avg_fields"]: AliasType<{
	id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** Boolean expression to filter rows from the table "goals". All fields are combined with a logical 'AND'. */
["goals_bool_exp"]: {
	_and?:ValueTypes["goals_bool_exp"][],
	_not?:ValueTypes["goals_bool_exp"],
	_or?:ValueTypes["goals_bool_exp"][],
	created?:ValueTypes["timestamptz_comparison_exp"],
	frequency?:ValueTypes["jsonb_comparison_exp"],
	id?:ValueTypes["Int_comparison_exp"],
	name?:ValueTypes["String_comparison_exp"],
	nl_description?:ValueTypes["String_comparison_exp"],
	status?:ValueTypes["String_comparison_exp"],
	todo?:ValueTypes["todos_bool_exp"],
	user?:ValueTypes["users_bool_exp"],
	user_id?:ValueTypes["Int_comparison_exp"]
};
	/** unique or primary key constraints on table "goals" */
["goals_constraint"]:goals_constraint;
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
["goals_delete_at_path_input"]: {
	frequency?:string[]
};
	/** delete the array element with specified index (negative integers count from the
end). throws an error if top level container is not an array */
["goals_delete_elem_input"]: {
	frequency?:number
};
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
["goals_delete_key_input"]: {
	frequency?:string
};
	/** input type for incrementing numeric columns in table "goals" */
["goals_inc_input"]: {
	id?:number,
	user_id?:number
};
	/** input type for inserting data into table "goals" */
["goals_insert_input"]: {
	created?:ValueTypes["timestamptz"],
	frequency?:ValueTypes["jsonb"],
	id?:number,
	name?:string,
	nl_description?:string,
	status?:string,
	todo?:ValueTypes["todos_obj_rel_insert_input"],
	user?:ValueTypes["users_obj_rel_insert_input"],
	user_id?:number
};
	/** aggregate max on columns */
["goals_max_fields"]: AliasType<{
	created?:true,
	id?:true,
	name?:true,
	nl_description?:true,
	status?:true,
	user_id?:true,
		__typename?: true
}>;
	/** aggregate min on columns */
["goals_min_fields"]: AliasType<{
	created?:true,
	id?:true,
	name?:true,
	nl_description?:true,
	status?:true,
	user_id?:true,
		__typename?: true
}>;
	/** response of any mutation on the table "goals" */
["goals_mutation_response"]: AliasType<{
	/** number of rows affected by the mutation */
	affected_rows?:true,
	/** data from the rows affected by the mutation */
	returning?:ValueTypes["goals"],
		__typename?: true
}>;
	/** input type for inserting object relation for remote table "goals" */
["goals_obj_rel_insert_input"]: {
	data:ValueTypes["goals_insert_input"],
	/** upsert condition */
	on_conflict?:ValueTypes["goals_on_conflict"]
};
	/** on_conflict condition type for table "goals" */
["goals_on_conflict"]: {
	constraint:ValueTypes["goals_constraint"],
	update_columns:ValueTypes["goals_update_column"][],
	where?:ValueTypes["goals_bool_exp"]
};
	/** Ordering options when selecting data from "goals". */
["goals_order_by"]: {
	created?:ValueTypes["order_by"],
	frequency?:ValueTypes["order_by"],
	id?:ValueTypes["order_by"],
	name?:ValueTypes["order_by"],
	nl_description?:ValueTypes["order_by"],
	status?:ValueTypes["order_by"],
	todo?:ValueTypes["todos_order_by"],
	user?:ValueTypes["users_order_by"],
	user_id?:ValueTypes["order_by"]
};
	/** primary key columns input for table: goals */
["goals_pk_columns_input"]: {
	id:number
};
	/** prepend existing jsonb value of filtered columns with new jsonb value */
["goals_prepend_input"]: {
	frequency?:ValueTypes["jsonb"]
};
	/** select columns of table "goals" */
["goals_select_column"]:goals_select_column;
	/** input type for updating data in table "goals" */
["goals_set_input"]: {
	created?:ValueTypes["timestamptz"],
	frequency?:ValueTypes["jsonb"],
	id?:number,
	name?:string,
	nl_description?:string,
	status?:string,
	user_id?:number
};
	/** aggregate stddev on columns */
["goals_stddev_fields"]: AliasType<{
	id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** aggregate stddev_pop on columns */
["goals_stddev_pop_fields"]: AliasType<{
	id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** aggregate stddev_samp on columns */
["goals_stddev_samp_fields"]: AliasType<{
	id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** Streaming cursor of the table "goals" */
["goals_stream_cursor_input"]: {
	/** Stream column input with initial value */
	initial_value:ValueTypes["goals_stream_cursor_value_input"],
	/** cursor ordering */
	ordering?:ValueTypes["cursor_ordering"]
};
	/** Initial value of the column from where the streaming should start */
["goals_stream_cursor_value_input"]: {
	created?:ValueTypes["timestamptz"],
	frequency?:ValueTypes["jsonb"],
	id?:number,
	name?:string,
	nl_description?:string,
	status?:string,
	user_id?:number
};
	/** aggregate sum on columns */
["goals_sum_fields"]: AliasType<{
	id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** update columns of table "goals" */
["goals_update_column"]:goals_update_column;
	["goals_updates"]: {
	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:ValueTypes["goals_append_input"],
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:ValueTypes["goals_delete_at_path_input"],
	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:ValueTypes["goals_delete_elem_input"],
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:ValueTypes["goals_delete_key_input"],
	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["goals_inc_input"],
	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:ValueTypes["goals_prepend_input"],
	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["goals_set_input"],
	/** filter the rows which have to be updated */
	where:ValueTypes["goals_bool_exp"]
};
	/** aggregate var_pop on columns */
["goals_var_pop_fields"]: AliasType<{
	id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** aggregate var_samp on columns */
["goals_var_samp_fields"]: AliasType<{
	id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** aggregate variance on columns */
["goals_variance_fields"]: AliasType<{
	id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** Boolean expression to compare columns of type "Int". All fields are combined with logical 'AND'. */
["Int_comparison_exp"]: {
	_eq?:number,
	_gt?:number,
	_gte?:number,
	_in?:number[],
	_is_null?:boolean,
	_lt?:number,
	_lte?:number,
	_neq?:number,
	_nin?:number[]
};
	/** columns and relationships of "interactions" */
["interactions"]: AliasType<{
	content?:true,
	content_type?:true,
debug?: [{	/** JSON select path */
	path?:string},true],
	embedding?:true,
events?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["events_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["events_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["events_bool_exp"]},ValueTypes["events"]],
events_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["events_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["events_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["events_bool_exp"]},ValueTypes["events_aggregate"]],
	id?:true,
	match_score?:true,
	timestamp?:true,
	user_id?:true,
		__typename?: true
}>;
	/** aggregated selection of "interactions" */
["interactions_aggregate"]: AliasType<{
	aggregate?:ValueTypes["interactions_aggregate_fields"],
	nodes?:ValueTypes["interactions"],
		__typename?: true
}>;
	/** aggregate fields of "interactions" */
["interactions_aggregate_fields"]: AliasType<{
	avg?:ValueTypes["interactions_avg_fields"],
count?: [{	columns?:ValueTypes["interactions_select_column"][],	distinct?:boolean},true],
	max?:ValueTypes["interactions_max_fields"],
	min?:ValueTypes["interactions_min_fields"],
	stddev?:ValueTypes["interactions_stddev_fields"],
	stddev_pop?:ValueTypes["interactions_stddev_pop_fields"],
	stddev_samp?:ValueTypes["interactions_stddev_samp_fields"],
	sum?:ValueTypes["interactions_sum_fields"],
	var_pop?:ValueTypes["interactions_var_pop_fields"],
	var_samp?:ValueTypes["interactions_var_samp_fields"],
	variance?:ValueTypes["interactions_variance_fields"],
		__typename?: true
}>;
	/** append existing jsonb value of filtered columns with new jsonb value */
["interactions_append_input"]: {
	debug?:ValueTypes["jsonb"]
};
	/** aggregate avg on columns */
["interactions_avg_fields"]: AliasType<{
	id?:true,
	match_score?:true,
	user_id?:true,
		__typename?: true
}>;
	/** Boolean expression to filter rows from the table "interactions". All fields are combined with a logical 'AND'. */
["interactions_bool_exp"]: {
	_and?:ValueTypes["interactions_bool_exp"][],
	_not?:ValueTypes["interactions_bool_exp"],
	_or?:ValueTypes["interactions_bool_exp"][],
	content?:ValueTypes["String_comparison_exp"],
	content_type?:ValueTypes["String_comparison_exp"],
	debug?:ValueTypes["jsonb_comparison_exp"],
	embedding?:ValueTypes["vector_comparison_exp"],
	events?:ValueTypes["events_bool_exp"],
	events_aggregate?:ValueTypes["events_aggregate_bool_exp"],
	id?:ValueTypes["Int_comparison_exp"],
	match_score?:ValueTypes["float8_comparison_exp"],
	timestamp?:ValueTypes["timestamptz_comparison_exp"],
	user_id?:ValueTypes["Int_comparison_exp"]
};
	/** unique or primary key constraints on table "interactions" */
["interactions_constraint"]:interactions_constraint;
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
["interactions_delete_at_path_input"]: {
	debug?:string[]
};
	/** delete the array element with specified index (negative integers count from the
end). throws an error if top level container is not an array */
["interactions_delete_elem_input"]: {
	debug?:number
};
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
["interactions_delete_key_input"]: {
	debug?:string
};
	/** input type for incrementing numeric columns in table "interactions" */
["interactions_inc_input"]: {
	id?:number,
	match_score?:ValueTypes["float8"],
	user_id?:number
};
	/** input type for inserting data into table "interactions" */
["interactions_insert_input"]: {
	content?:string,
	content_type?:string,
	debug?:ValueTypes["jsonb"],
	embedding?:ValueTypes["vector"],
	events?:ValueTypes["events_arr_rel_insert_input"],
	id?:number,
	match_score?:ValueTypes["float8"],
	timestamp?:ValueTypes["timestamptz"],
	user_id?:number
};
	/** aggregate max on columns */
["interactions_max_fields"]: AliasType<{
	content?:true,
	content_type?:true,
	id?:true,
	match_score?:true,
	timestamp?:true,
	user_id?:true,
		__typename?: true
}>;
	/** aggregate min on columns */
["interactions_min_fields"]: AliasType<{
	content?:true,
	content_type?:true,
	id?:true,
	match_score?:true,
	timestamp?:true,
	user_id?:true,
		__typename?: true
}>;
	/** response of any mutation on the table "interactions" */
["interactions_mutation_response"]: AliasType<{
	/** number of rows affected by the mutation */
	affected_rows?:true,
	/** data from the rows affected by the mutation */
	returning?:ValueTypes["interactions"],
		__typename?: true
}>;
	/** input type for inserting object relation for remote table "interactions" */
["interactions_obj_rel_insert_input"]: {
	data:ValueTypes["interactions_insert_input"],
	/** upsert condition */
	on_conflict?:ValueTypes["interactions_on_conflict"]
};
	/** on_conflict condition type for table "interactions" */
["interactions_on_conflict"]: {
	constraint:ValueTypes["interactions_constraint"],
	update_columns:ValueTypes["interactions_update_column"][],
	where?:ValueTypes["interactions_bool_exp"]
};
	/** Ordering options when selecting data from "interactions". */
["interactions_order_by"]: {
	content?:ValueTypes["order_by"],
	content_type?:ValueTypes["order_by"],
	debug?:ValueTypes["order_by"],
	embedding?:ValueTypes["order_by"],
	events_aggregate?:ValueTypes["events_aggregate_order_by"],
	id?:ValueTypes["order_by"],
	match_score?:ValueTypes["order_by"],
	timestamp?:ValueTypes["order_by"],
	user_id?:ValueTypes["order_by"]
};
	/** primary key columns input for table: interactions */
["interactions_pk_columns_input"]: {
	id:number
};
	/** prepend existing jsonb value of filtered columns with new jsonb value */
["interactions_prepend_input"]: {
	debug?:ValueTypes["jsonb"]
};
	/** select columns of table "interactions" */
["interactions_select_column"]:interactions_select_column;
	/** input type for updating data in table "interactions" */
["interactions_set_input"]: {
	content?:string,
	content_type?:string,
	debug?:ValueTypes["jsonb"],
	embedding?:ValueTypes["vector"],
	id?:number,
	match_score?:ValueTypes["float8"],
	timestamp?:ValueTypes["timestamptz"],
	user_id?:number
};
	/** aggregate stddev on columns */
["interactions_stddev_fields"]: AliasType<{
	id?:true,
	match_score?:true,
	user_id?:true,
		__typename?: true
}>;
	/** aggregate stddev_pop on columns */
["interactions_stddev_pop_fields"]: AliasType<{
	id?:true,
	match_score?:true,
	user_id?:true,
		__typename?: true
}>;
	/** aggregate stddev_samp on columns */
["interactions_stddev_samp_fields"]: AliasType<{
	id?:true,
	match_score?:true,
	user_id?:true,
		__typename?: true
}>;
	/** Streaming cursor of the table "interactions" */
["interactions_stream_cursor_input"]: {
	/** Stream column input with initial value */
	initial_value:ValueTypes["interactions_stream_cursor_value_input"],
	/** cursor ordering */
	ordering?:ValueTypes["cursor_ordering"]
};
	/** Initial value of the column from where the streaming should start */
["interactions_stream_cursor_value_input"]: {
	content?:string,
	content_type?:string,
	debug?:ValueTypes["jsonb"],
	embedding?:ValueTypes["vector"],
	id?:number,
	match_score?:ValueTypes["float8"],
	timestamp?:ValueTypes["timestamptz"],
	user_id?:number
};
	/** aggregate sum on columns */
["interactions_sum_fields"]: AliasType<{
	id?:true,
	match_score?:true,
	user_id?:true,
		__typename?: true
}>;
	/** update columns of table "interactions" */
["interactions_update_column"]:interactions_update_column;
	["interactions_updates"]: {
	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:ValueTypes["interactions_append_input"],
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:ValueTypes["interactions_delete_at_path_input"],
	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:ValueTypes["interactions_delete_elem_input"],
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:ValueTypes["interactions_delete_key_input"],
	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["interactions_inc_input"],
	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:ValueTypes["interactions_prepend_input"],
	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["interactions_set_input"],
	/** filter the rows which have to be updated */
	where:ValueTypes["interactions_bool_exp"]
};
	/** aggregate var_pop on columns */
["interactions_var_pop_fields"]: AliasType<{
	id?:true,
	match_score?:true,
	user_id?:true,
		__typename?: true
}>;
	/** aggregate var_samp on columns */
["interactions_var_samp_fields"]: AliasType<{
	id?:true,
	match_score?:true,
	user_id?:true,
		__typename?: true
}>;
	/** aggregate variance on columns */
["interactions_variance_fields"]: AliasType<{
	id?:true,
	match_score?:true,
	user_id?:true,
		__typename?: true
}>;
	["jsonb"]:unknown;
	["jsonb_cast_exp"]: {
	String?:ValueTypes["String_comparison_exp"]
};
	/** Boolean expression to compare columns of type "jsonb". All fields are combined with logical 'AND'. */
["jsonb_comparison_exp"]: {
	_cast?:ValueTypes["jsonb_cast_exp"],
	/** is the column contained in the given json value */
	_contained_in?:ValueTypes["jsonb"],
	/** does the column contain the given json value at the top level */
	_contains?:ValueTypes["jsonb"],
	_eq?:ValueTypes["jsonb"],
	_gt?:ValueTypes["jsonb"],
	_gte?:ValueTypes["jsonb"],
	/** does the string exist as a top-level key in the column */
	_has_key?:string,
	/** do all of these strings exist as top-level keys in the column */
	_has_keys_all?:string[],
	/** do any of these strings exist as top-level keys in the column */
	_has_keys_any?:string[],
	_in?:ValueTypes["jsonb"][],
	_is_null?:boolean,
	_lt?:ValueTypes["jsonb"],
	_lte?:ValueTypes["jsonb"],
	_neq?:ValueTypes["jsonb"],
	_nin?:ValueTypes["jsonb"][]
};
	/** columns and relationships of "locations" */
["locations"]: AliasType<{
	id?:true,
	location?:true,
	name?:true,
	user_id?:true,
		__typename?: true
}>;
	["locations_aggregate"]: AliasType<{
	aggregate?:ValueTypes["locations_aggregate_fields"],
	nodes?:ValueTypes["locations"],
		__typename?: true
}>;
	["locations_aggregate_bool_exp"]: {
	count?:ValueTypes["locations_aggregate_bool_exp_count"]
};
	["locations_aggregate_bool_exp_count"]: {
	arguments?:ValueTypes["locations_select_column"][],
	distinct?:boolean,
	filter?:ValueTypes["locations_bool_exp"],
	predicate:ValueTypes["Int_comparison_exp"]
};
	/** aggregate fields of "locations" */
["locations_aggregate_fields"]: AliasType<{
	avg?:ValueTypes["locations_avg_fields"],
count?: [{	columns?:ValueTypes["locations_select_column"][],	distinct?:boolean},true],
	max?:ValueTypes["locations_max_fields"],
	min?:ValueTypes["locations_min_fields"],
	stddev?:ValueTypes["locations_stddev_fields"],
	stddev_pop?:ValueTypes["locations_stddev_pop_fields"],
	stddev_samp?:ValueTypes["locations_stddev_samp_fields"],
	sum?:ValueTypes["locations_sum_fields"],
	var_pop?:ValueTypes["locations_var_pop_fields"],
	var_samp?:ValueTypes["locations_var_samp_fields"],
	variance?:ValueTypes["locations_variance_fields"],
		__typename?: true
}>;
	/** order by aggregate values of table "locations" */
["locations_aggregate_order_by"]: {
	avg?:ValueTypes["locations_avg_order_by"],
	count?:ValueTypes["order_by"],
	max?:ValueTypes["locations_max_order_by"],
	min?:ValueTypes["locations_min_order_by"],
	stddev?:ValueTypes["locations_stddev_order_by"],
	stddev_pop?:ValueTypes["locations_stddev_pop_order_by"],
	stddev_samp?:ValueTypes["locations_stddev_samp_order_by"],
	sum?:ValueTypes["locations_sum_order_by"],
	var_pop?:ValueTypes["locations_var_pop_order_by"],
	var_samp?:ValueTypes["locations_var_samp_order_by"],
	variance?:ValueTypes["locations_variance_order_by"]
};
	/** input type for inserting array relation for remote table "locations" */
["locations_arr_rel_insert_input"]: {
	data:ValueTypes["locations_insert_input"][],
	/** upsert condition */
	on_conflict?:ValueTypes["locations_on_conflict"]
};
	/** aggregate avg on columns */
["locations_avg_fields"]: AliasType<{
	id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** order by avg() on columns of table "locations" */
["locations_avg_order_by"]: {
	id?:ValueTypes["order_by"],
	user_id?:ValueTypes["order_by"]
};
	/** Boolean expression to filter rows from the table "locations". All fields are combined with a logical 'AND'. */
["locations_bool_exp"]: {
	_and?:ValueTypes["locations_bool_exp"][],
	_not?:ValueTypes["locations_bool_exp"],
	_or?:ValueTypes["locations_bool_exp"][],
	id?:ValueTypes["Int_comparison_exp"],
	location?:ValueTypes["geography_comparison_exp"],
	name?:ValueTypes["String_comparison_exp"],
	user_id?:ValueTypes["Int_comparison_exp"]
};
	/** unique or primary key constraints on table "locations" */
["locations_constraint"]:locations_constraint;
	/** input type for incrementing numeric columns in table "locations" */
["locations_inc_input"]: {
	id?:number,
	user_id?:number
};
	/** input type for inserting data into table "locations" */
["locations_insert_input"]: {
	id?:number,
	location?:ValueTypes["geography"],
	name?:string,
	user_id?:number
};
	/** aggregate max on columns */
["locations_max_fields"]: AliasType<{
	id?:true,
	name?:true,
	user_id?:true,
		__typename?: true
}>;
	/** order by max() on columns of table "locations" */
["locations_max_order_by"]: {
	id?:ValueTypes["order_by"],
	name?:ValueTypes["order_by"],
	user_id?:ValueTypes["order_by"]
};
	/** aggregate min on columns */
["locations_min_fields"]: AliasType<{
	id?:true,
	name?:true,
	user_id?:true,
		__typename?: true
}>;
	/** order by min() on columns of table "locations" */
["locations_min_order_by"]: {
	id?:ValueTypes["order_by"],
	name?:ValueTypes["order_by"],
	user_id?:ValueTypes["order_by"]
};
	/** response of any mutation on the table "locations" */
["locations_mutation_response"]: AliasType<{
	/** number of rows affected by the mutation */
	affected_rows?:true,
	/** data from the rows affected by the mutation */
	returning?:ValueTypes["locations"],
		__typename?: true
}>;
	/** on_conflict condition type for table "locations" */
["locations_on_conflict"]: {
	constraint:ValueTypes["locations_constraint"],
	update_columns:ValueTypes["locations_update_column"][],
	where?:ValueTypes["locations_bool_exp"]
};
	/** Ordering options when selecting data from "locations". */
["locations_order_by"]: {
	id?:ValueTypes["order_by"],
	location?:ValueTypes["order_by"],
	name?:ValueTypes["order_by"],
	user_id?:ValueTypes["order_by"]
};
	/** primary key columns input for table: locations */
["locations_pk_columns_input"]: {
	id:number
};
	/** select columns of table "locations" */
["locations_select_column"]:locations_select_column;
	/** input type for updating data in table "locations" */
["locations_set_input"]: {
	id?:number,
	location?:ValueTypes["geography"],
	name?:string,
	user_id?:number
};
	/** aggregate stddev on columns */
["locations_stddev_fields"]: AliasType<{
	id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** order by stddev() on columns of table "locations" */
["locations_stddev_order_by"]: {
	id?:ValueTypes["order_by"],
	user_id?:ValueTypes["order_by"]
};
	/** aggregate stddev_pop on columns */
["locations_stddev_pop_fields"]: AliasType<{
	id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** order by stddev_pop() on columns of table "locations" */
["locations_stddev_pop_order_by"]: {
	id?:ValueTypes["order_by"],
	user_id?:ValueTypes["order_by"]
};
	/** aggregate stddev_samp on columns */
["locations_stddev_samp_fields"]: AliasType<{
	id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** order by stddev_samp() on columns of table "locations" */
["locations_stddev_samp_order_by"]: {
	id?:ValueTypes["order_by"],
	user_id?:ValueTypes["order_by"]
};
	/** Streaming cursor of the table "locations" */
["locations_stream_cursor_input"]: {
	/** Stream column input with initial value */
	initial_value:ValueTypes["locations_stream_cursor_value_input"],
	/** cursor ordering */
	ordering?:ValueTypes["cursor_ordering"]
};
	/** Initial value of the column from where the streaming should start */
["locations_stream_cursor_value_input"]: {
	id?:number,
	location?:ValueTypes["geography"],
	name?:string,
	user_id?:number
};
	/** aggregate sum on columns */
["locations_sum_fields"]: AliasType<{
	id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** order by sum() on columns of table "locations" */
["locations_sum_order_by"]: {
	id?:ValueTypes["order_by"],
	user_id?:ValueTypes["order_by"]
};
	/** update columns of table "locations" */
["locations_update_column"]:locations_update_column;
	["locations_updates"]: {
	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["locations_inc_input"],
	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["locations_set_input"],
	/** filter the rows which have to be updated */
	where:ValueTypes["locations_bool_exp"]
};
	/** aggregate var_pop on columns */
["locations_var_pop_fields"]: AliasType<{
	id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** order by var_pop() on columns of table "locations" */
["locations_var_pop_order_by"]: {
	id?:ValueTypes["order_by"],
	user_id?:ValueTypes["order_by"]
};
	/** aggregate var_samp on columns */
["locations_var_samp_fields"]: AliasType<{
	id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** order by var_samp() on columns of table "locations" */
["locations_var_samp_order_by"]: {
	id?:ValueTypes["order_by"],
	user_id?:ValueTypes["order_by"]
};
	/** aggregate variance on columns */
["locations_variance_fields"]: AliasType<{
	id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** order by variance() on columns of table "locations" */
["locations_variance_order_by"]: {
	id?:ValueTypes["order_by"],
	user_id?:ValueTypes["order_by"]
};
	["match_interactions_args"]: {
	match_threshold?:ValueTypes["float8"],
	query_embedding?:ValueTypes["vector"],
	target_user_id?:number
};
	/** mutation root */
["mutation_root"]: AliasType<{
delete_associations?: [{	/** filter the rows which have to be deleted */
	where:ValueTypes["associations_bool_exp"]},ValueTypes["associations_mutation_response"]],
delete_associations_by_pk?: [{	id:number},ValueTypes["associations"]],
delete_event_tag?: [{	/** filter the rows which have to be deleted */
	where:ValueTypes["event_tag_bool_exp"]},ValueTypes["event_tag_mutation_response"]],
delete_event_tag_by_pk?: [{	event_id:number,	tag_name:string},ValueTypes["event_tag"]],
delete_event_types?: [{	/** filter the rows which have to be deleted */
	where:ValueTypes["event_types_bool_exp"]},ValueTypes["event_types_mutation_response"]],
delete_event_types_by_pk?: [{	name:string},ValueTypes["event_types"]],
delete_events?: [{	/** filter the rows which have to be deleted */
	where:ValueTypes["events_bool_exp"]},ValueTypes["events_mutation_response"]],
delete_events_by_pk?: [{	id:number},ValueTypes["events"]],
delete_goals?: [{	/** filter the rows which have to be deleted */
	where:ValueTypes["goals_bool_exp"]},ValueTypes["goals_mutation_response"]],
delete_goals_by_pk?: [{	id:number},ValueTypes["goals"]],
delete_interactions?: [{	/** filter the rows which have to be deleted */
	where:ValueTypes["interactions_bool_exp"]},ValueTypes["interactions_mutation_response"]],
delete_interactions_by_pk?: [{	id:number},ValueTypes["interactions"]],
delete_locations?: [{	/** filter the rows which have to be deleted */
	where:ValueTypes["locations_bool_exp"]},ValueTypes["locations_mutation_response"]],
delete_locations_by_pk?: [{	id:number},ValueTypes["locations"]],
delete_object_types?: [{	/** filter the rows which have to be deleted */
	where:ValueTypes["object_types_bool_exp"]},ValueTypes["object_types_mutation_response"]],
delete_object_types_by_pk?: [{	id:string},ValueTypes["object_types"]],
delete_objects?: [{	/** filter the rows which have to be deleted */
	where:ValueTypes["objects_bool_exp"]},ValueTypes["objects_mutation_response"]],
delete_objects_by_pk?: [{	id:number},ValueTypes["objects"]],
delete_todos?: [{	/** filter the rows which have to be deleted */
	where:ValueTypes["todos_bool_exp"]},ValueTypes["todos_mutation_response"]],
delete_todos_by_pk?: [{	id:number},ValueTypes["todos"]],
delete_users?: [{	/** filter the rows which have to be deleted */
	where:ValueTypes["users_bool_exp"]},ValueTypes["users_mutation_response"]],
delete_users_by_pk?: [{	id:number},ValueTypes["users"]],
insert_associations?: [{	/** the rows to be inserted */
	objects:ValueTypes["associations_insert_input"][],	/** upsert condition */
	on_conflict?:ValueTypes["associations_on_conflict"]},ValueTypes["associations_mutation_response"]],
insert_associations_one?: [{	/** the row to be inserted */
	object:ValueTypes["associations_insert_input"],	/** upsert condition */
	on_conflict?:ValueTypes["associations_on_conflict"]},ValueTypes["associations"]],
insert_event_tag?: [{	/** the rows to be inserted */
	objects:ValueTypes["event_tag_insert_input"][],	/** upsert condition */
	on_conflict?:ValueTypes["event_tag_on_conflict"]},ValueTypes["event_tag_mutation_response"]],
insert_event_tag_one?: [{	/** the row to be inserted */
	object:ValueTypes["event_tag_insert_input"],	/** upsert condition */
	on_conflict?:ValueTypes["event_tag_on_conflict"]},ValueTypes["event_tag"]],
insert_event_types?: [{	/** the rows to be inserted */
	objects:ValueTypes["event_types_insert_input"][],	/** upsert condition */
	on_conflict?:ValueTypes["event_types_on_conflict"]},ValueTypes["event_types_mutation_response"]],
insert_event_types_one?: [{	/** the row to be inserted */
	object:ValueTypes["event_types_insert_input"],	/** upsert condition */
	on_conflict?:ValueTypes["event_types_on_conflict"]},ValueTypes["event_types"]],
insert_events?: [{	/** the rows to be inserted */
	objects:ValueTypes["events_insert_input"][],	/** upsert condition */
	on_conflict?:ValueTypes["events_on_conflict"]},ValueTypes["events_mutation_response"]],
insert_events_one?: [{	/** the row to be inserted */
	object:ValueTypes["events_insert_input"],	/** upsert condition */
	on_conflict?:ValueTypes["events_on_conflict"]},ValueTypes["events"]],
insert_goals?: [{	/** the rows to be inserted */
	objects:ValueTypes["goals_insert_input"][],	/** upsert condition */
	on_conflict?:ValueTypes["goals_on_conflict"]},ValueTypes["goals_mutation_response"]],
insert_goals_one?: [{	/** the row to be inserted */
	object:ValueTypes["goals_insert_input"],	/** upsert condition */
	on_conflict?:ValueTypes["goals_on_conflict"]},ValueTypes["goals"]],
insert_interactions?: [{	/** the rows to be inserted */
	objects:ValueTypes["interactions_insert_input"][],	/** upsert condition */
	on_conflict?:ValueTypes["interactions_on_conflict"]},ValueTypes["interactions_mutation_response"]],
insert_interactions_one?: [{	/** the row to be inserted */
	object:ValueTypes["interactions_insert_input"],	/** upsert condition */
	on_conflict?:ValueTypes["interactions_on_conflict"]},ValueTypes["interactions"]],
insert_locations?: [{	/** the rows to be inserted */
	objects:ValueTypes["locations_insert_input"][],	/** upsert condition */
	on_conflict?:ValueTypes["locations_on_conflict"]},ValueTypes["locations_mutation_response"]],
insert_locations_one?: [{	/** the row to be inserted */
	object:ValueTypes["locations_insert_input"],	/** upsert condition */
	on_conflict?:ValueTypes["locations_on_conflict"]},ValueTypes["locations"]],
insert_object_types?: [{	/** the rows to be inserted */
	objects:ValueTypes["object_types_insert_input"][],	/** upsert condition */
	on_conflict?:ValueTypes["object_types_on_conflict"]},ValueTypes["object_types_mutation_response"]],
insert_object_types_one?: [{	/** the row to be inserted */
	object:ValueTypes["object_types_insert_input"],	/** upsert condition */
	on_conflict?:ValueTypes["object_types_on_conflict"]},ValueTypes["object_types"]],
insert_objects?: [{	/** the rows to be inserted */
	objects:ValueTypes["objects_insert_input"][],	/** upsert condition */
	on_conflict?:ValueTypes["objects_on_conflict"]},ValueTypes["objects_mutation_response"]],
insert_objects_one?: [{	/** the row to be inserted */
	object:ValueTypes["objects_insert_input"],	/** upsert condition */
	on_conflict?:ValueTypes["objects_on_conflict"]},ValueTypes["objects"]],
insert_todos?: [{	/** the rows to be inserted */
	objects:ValueTypes["todos_insert_input"][],	/** upsert condition */
	on_conflict?:ValueTypes["todos_on_conflict"]},ValueTypes["todos_mutation_response"]],
insert_todos_one?: [{	/** the row to be inserted */
	object:ValueTypes["todos_insert_input"],	/** upsert condition */
	on_conflict?:ValueTypes["todos_on_conflict"]},ValueTypes["todos"]],
insert_users?: [{	/** the rows to be inserted */
	objects:ValueTypes["users_insert_input"][],	/** upsert condition */
	on_conflict?:ValueTypes["users_on_conflict"]},ValueTypes["users_mutation_response"]],
insert_users_one?: [{	/** the row to be inserted */
	object:ValueTypes["users_insert_input"],	/** upsert condition */
	on_conflict?:ValueTypes["users_on_conflict"]},ValueTypes["users"]],
update_associations?: [{	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:ValueTypes["associations_append_input"],	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:ValueTypes["associations_delete_at_path_input"],	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:ValueTypes["associations_delete_elem_input"],	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:ValueTypes["associations_delete_key_input"],	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["associations_inc_input"],	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:ValueTypes["associations_prepend_input"],	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["associations_set_input"],	/** filter the rows which have to be updated */
	where:ValueTypes["associations_bool_exp"]},ValueTypes["associations_mutation_response"]],
update_associations_by_pk?: [{	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:ValueTypes["associations_append_input"],	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:ValueTypes["associations_delete_at_path_input"],	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:ValueTypes["associations_delete_elem_input"],	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:ValueTypes["associations_delete_key_input"],	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["associations_inc_input"],	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:ValueTypes["associations_prepend_input"],	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["associations_set_input"],	pk_columns:ValueTypes["associations_pk_columns_input"]},ValueTypes["associations"]],
update_associations_many?: [{	/** updates to execute, in order */
	updates:ValueTypes["associations_updates"][]},ValueTypes["associations_mutation_response"]],
update_event_tag?: [{	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["event_tag_inc_input"],	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["event_tag_set_input"],	/** filter the rows which have to be updated */
	where:ValueTypes["event_tag_bool_exp"]},ValueTypes["event_tag_mutation_response"]],
update_event_tag_by_pk?: [{	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["event_tag_inc_input"],	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["event_tag_set_input"],	pk_columns:ValueTypes["event_tag_pk_columns_input"]},ValueTypes["event_tag"]],
update_event_tag_many?: [{	/** updates to execute, in order */
	updates:ValueTypes["event_tag_updates"][]},ValueTypes["event_tag_mutation_response"]],
update_event_types?: [{	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:ValueTypes["event_types_append_input"],	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:ValueTypes["event_types_delete_at_path_input"],	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:ValueTypes["event_types_delete_elem_input"],	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:ValueTypes["event_types_delete_key_input"],	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:ValueTypes["event_types_prepend_input"],	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["event_types_set_input"],	/** filter the rows which have to be updated */
	where:ValueTypes["event_types_bool_exp"]},ValueTypes["event_types_mutation_response"]],
update_event_types_by_pk?: [{	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:ValueTypes["event_types_append_input"],	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:ValueTypes["event_types_delete_at_path_input"],	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:ValueTypes["event_types_delete_elem_input"],	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:ValueTypes["event_types_delete_key_input"],	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:ValueTypes["event_types_prepend_input"],	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["event_types_set_input"],	pk_columns:ValueTypes["event_types_pk_columns_input"]},ValueTypes["event_types"]],
update_event_types_many?: [{	/** updates to execute, in order */
	updates:ValueTypes["event_types_updates"][]},ValueTypes["event_types_mutation_response"]],
update_events?: [{	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:ValueTypes["events_append_input"],	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:ValueTypes["events_delete_at_path_input"],	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:ValueTypes["events_delete_elem_input"],	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:ValueTypes["events_delete_key_input"],	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["events_inc_input"],	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:ValueTypes["events_prepend_input"],	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["events_set_input"],	/** filter the rows which have to be updated */
	where:ValueTypes["events_bool_exp"]},ValueTypes["events_mutation_response"]],
update_events_by_pk?: [{	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:ValueTypes["events_append_input"],	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:ValueTypes["events_delete_at_path_input"],	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:ValueTypes["events_delete_elem_input"],	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:ValueTypes["events_delete_key_input"],	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["events_inc_input"],	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:ValueTypes["events_prepend_input"],	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["events_set_input"],	pk_columns:ValueTypes["events_pk_columns_input"]},ValueTypes["events"]],
update_events_many?: [{	/** updates to execute, in order */
	updates:ValueTypes["events_updates"][]},ValueTypes["events_mutation_response"]],
update_goals?: [{	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:ValueTypes["goals_append_input"],	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:ValueTypes["goals_delete_at_path_input"],	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:ValueTypes["goals_delete_elem_input"],	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:ValueTypes["goals_delete_key_input"],	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["goals_inc_input"],	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:ValueTypes["goals_prepend_input"],	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["goals_set_input"],	/** filter the rows which have to be updated */
	where:ValueTypes["goals_bool_exp"]},ValueTypes["goals_mutation_response"]],
update_goals_by_pk?: [{	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:ValueTypes["goals_append_input"],	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:ValueTypes["goals_delete_at_path_input"],	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:ValueTypes["goals_delete_elem_input"],	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:ValueTypes["goals_delete_key_input"],	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["goals_inc_input"],	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:ValueTypes["goals_prepend_input"],	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["goals_set_input"],	pk_columns:ValueTypes["goals_pk_columns_input"]},ValueTypes["goals"]],
update_goals_many?: [{	/** updates to execute, in order */
	updates:ValueTypes["goals_updates"][]},ValueTypes["goals_mutation_response"]],
update_interactions?: [{	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:ValueTypes["interactions_append_input"],	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:ValueTypes["interactions_delete_at_path_input"],	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:ValueTypes["interactions_delete_elem_input"],	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:ValueTypes["interactions_delete_key_input"],	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["interactions_inc_input"],	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:ValueTypes["interactions_prepend_input"],	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["interactions_set_input"],	/** filter the rows which have to be updated */
	where:ValueTypes["interactions_bool_exp"]},ValueTypes["interactions_mutation_response"]],
update_interactions_by_pk?: [{	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:ValueTypes["interactions_append_input"],	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:ValueTypes["interactions_delete_at_path_input"],	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:ValueTypes["interactions_delete_elem_input"],	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:ValueTypes["interactions_delete_key_input"],	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["interactions_inc_input"],	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:ValueTypes["interactions_prepend_input"],	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["interactions_set_input"],	pk_columns:ValueTypes["interactions_pk_columns_input"]},ValueTypes["interactions"]],
update_interactions_many?: [{	/** updates to execute, in order */
	updates:ValueTypes["interactions_updates"][]},ValueTypes["interactions_mutation_response"]],
update_locations?: [{	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["locations_inc_input"],	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["locations_set_input"],	/** filter the rows which have to be updated */
	where:ValueTypes["locations_bool_exp"]},ValueTypes["locations_mutation_response"]],
update_locations_by_pk?: [{	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["locations_inc_input"],	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["locations_set_input"],	pk_columns:ValueTypes["locations_pk_columns_input"]},ValueTypes["locations"]],
update_locations_many?: [{	/** updates to execute, in order */
	updates:ValueTypes["locations_updates"][]},ValueTypes["locations_mutation_response"]],
update_object_types?: [{	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:ValueTypes["object_types_append_input"],	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:ValueTypes["object_types_delete_at_path_input"],	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:ValueTypes["object_types_delete_elem_input"],	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:ValueTypes["object_types_delete_key_input"],	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:ValueTypes["object_types_prepend_input"],	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["object_types_set_input"],	/** filter the rows which have to be updated */
	where:ValueTypes["object_types_bool_exp"]},ValueTypes["object_types_mutation_response"]],
update_object_types_by_pk?: [{	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:ValueTypes["object_types_append_input"],	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:ValueTypes["object_types_delete_at_path_input"],	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:ValueTypes["object_types_delete_elem_input"],	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:ValueTypes["object_types_delete_key_input"],	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:ValueTypes["object_types_prepend_input"],	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["object_types_set_input"],	pk_columns:ValueTypes["object_types_pk_columns_input"]},ValueTypes["object_types"]],
update_object_types_many?: [{	/** updates to execute, in order */
	updates:ValueTypes["object_types_updates"][]},ValueTypes["object_types_mutation_response"]],
update_objects?: [{	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["objects_inc_input"],	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["objects_set_input"],	/** filter the rows which have to be updated */
	where:ValueTypes["objects_bool_exp"]},ValueTypes["objects_mutation_response"]],
update_objects_by_pk?: [{	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["objects_inc_input"],	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["objects_set_input"],	pk_columns:ValueTypes["objects_pk_columns_input"]},ValueTypes["objects"]],
update_objects_many?: [{	/** updates to execute, in order */
	updates:ValueTypes["objects_updates"][]},ValueTypes["objects_mutation_response"]],
update_todos?: [{	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["todos_inc_input"],	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["todos_set_input"],	/** filter the rows which have to be updated */
	where:ValueTypes["todos_bool_exp"]},ValueTypes["todos_mutation_response"]],
update_todos_by_pk?: [{	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["todos_inc_input"],	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["todos_set_input"],	pk_columns:ValueTypes["todos_pk_columns_input"]},ValueTypes["todos"]],
update_todos_many?: [{	/** updates to execute, in order */
	updates:ValueTypes["todos_updates"][]},ValueTypes["todos_mutation_response"]],
update_users?: [{	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:ValueTypes["users_append_input"],	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:ValueTypes["users_delete_at_path_input"],	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:ValueTypes["users_delete_elem_input"],	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:ValueTypes["users_delete_key_input"],	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["users_inc_input"],	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:ValueTypes["users_prepend_input"],	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["users_set_input"],	/** filter the rows which have to be updated */
	where:ValueTypes["users_bool_exp"]},ValueTypes["users_mutation_response"]],
update_users_by_pk?: [{	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:ValueTypes["users_append_input"],	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:ValueTypes["users_delete_at_path_input"],	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:ValueTypes["users_delete_elem_input"],	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:ValueTypes["users_delete_key_input"],	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["users_inc_input"],	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:ValueTypes["users_prepend_input"],	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["users_set_input"],	pk_columns:ValueTypes["users_pk_columns_input"]},ValueTypes["users"]],
update_users_many?: [{	/** updates to execute, in order */
	updates:ValueTypes["users_updates"][]},ValueTypes["users_mutation_response"]],
		__typename?: true
}>;
	/** columns and relationships of "object_types" */
["object_types"]: AliasType<{
	id?:true,
metadata?: [{	/** JSON select path */
	path?:string},true],
		__typename?: true
}>;
	/** aggregated selection of "object_types" */
["object_types_aggregate"]: AliasType<{
	aggregate?:ValueTypes["object_types_aggregate_fields"],
	nodes?:ValueTypes["object_types"],
		__typename?: true
}>;
	/** aggregate fields of "object_types" */
["object_types_aggregate_fields"]: AliasType<{
count?: [{	columns?:ValueTypes["object_types_select_column"][],	distinct?:boolean},true],
	max?:ValueTypes["object_types_max_fields"],
	min?:ValueTypes["object_types_min_fields"],
		__typename?: true
}>;
	/** append existing jsonb value of filtered columns with new jsonb value */
["object_types_append_input"]: {
	metadata?:ValueTypes["jsonb"]
};
	/** Boolean expression to filter rows from the table "object_types". All fields are combined with a logical 'AND'. */
["object_types_bool_exp"]: {
	_and?:ValueTypes["object_types_bool_exp"][],
	_not?:ValueTypes["object_types_bool_exp"],
	_or?:ValueTypes["object_types_bool_exp"][],
	id?:ValueTypes["String_comparison_exp"],
	metadata?:ValueTypes["jsonb_comparison_exp"]
};
	/** unique or primary key constraints on table "object_types" */
["object_types_constraint"]:object_types_constraint;
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
["object_types_delete_at_path_input"]: {
	metadata?:string[]
};
	/** delete the array element with specified index (negative integers count from the
end). throws an error if top level container is not an array */
["object_types_delete_elem_input"]: {
	metadata?:number
};
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
["object_types_delete_key_input"]: {
	metadata?:string
};
	/** input type for inserting data into table "object_types" */
["object_types_insert_input"]: {
	id?:string,
	metadata?:ValueTypes["jsonb"]
};
	/** aggregate max on columns */
["object_types_max_fields"]: AliasType<{
	id?:true,
		__typename?: true
}>;
	/** aggregate min on columns */
["object_types_min_fields"]: AliasType<{
	id?:true,
		__typename?: true
}>;
	/** response of any mutation on the table "object_types" */
["object_types_mutation_response"]: AliasType<{
	/** number of rows affected by the mutation */
	affected_rows?:true,
	/** data from the rows affected by the mutation */
	returning?:ValueTypes["object_types"],
		__typename?: true
}>;
	/** on_conflict condition type for table "object_types" */
["object_types_on_conflict"]: {
	constraint:ValueTypes["object_types_constraint"],
	update_columns:ValueTypes["object_types_update_column"][],
	where?:ValueTypes["object_types_bool_exp"]
};
	/** Ordering options when selecting data from "object_types". */
["object_types_order_by"]: {
	id?:ValueTypes["order_by"],
	metadata?:ValueTypes["order_by"]
};
	/** primary key columns input for table: object_types */
["object_types_pk_columns_input"]: {
	id:string
};
	/** prepend existing jsonb value of filtered columns with new jsonb value */
["object_types_prepend_input"]: {
	metadata?:ValueTypes["jsonb"]
};
	/** select columns of table "object_types" */
["object_types_select_column"]:object_types_select_column;
	/** input type for updating data in table "object_types" */
["object_types_set_input"]: {
	id?:string,
	metadata?:ValueTypes["jsonb"]
};
	/** Streaming cursor of the table "object_types" */
["object_types_stream_cursor_input"]: {
	/** Stream column input with initial value */
	initial_value:ValueTypes["object_types_stream_cursor_value_input"],
	/** cursor ordering */
	ordering?:ValueTypes["cursor_ordering"]
};
	/** Initial value of the column from where the streaming should start */
["object_types_stream_cursor_value_input"]: {
	id?:string,
	metadata?:ValueTypes["jsonb"]
};
	/** update columns of table "object_types" */
["object_types_update_column"]:object_types_update_column;
	["object_types_updates"]: {
	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:ValueTypes["object_types_append_input"],
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:ValueTypes["object_types_delete_at_path_input"],
	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:ValueTypes["object_types_delete_elem_input"],
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:ValueTypes["object_types_delete_key_input"],
	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:ValueTypes["object_types_prepend_input"],
	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["object_types_set_input"],
	/** filter the rows which have to be updated */
	where:ValueTypes["object_types_bool_exp"]
};
	/** columns and relationships of "objects" */
["objects"]: AliasType<{
	id?:true,
	name?:true,
	object_type?:true,
		__typename?: true
}>;
	/** aggregated selection of "objects" */
["objects_aggregate"]: AliasType<{
	aggregate?:ValueTypes["objects_aggregate_fields"],
	nodes?:ValueTypes["objects"],
		__typename?: true
}>;
	/** aggregate fields of "objects" */
["objects_aggregate_fields"]: AliasType<{
	avg?:ValueTypes["objects_avg_fields"],
count?: [{	columns?:ValueTypes["objects_select_column"][],	distinct?:boolean},true],
	max?:ValueTypes["objects_max_fields"],
	min?:ValueTypes["objects_min_fields"],
	stddev?:ValueTypes["objects_stddev_fields"],
	stddev_pop?:ValueTypes["objects_stddev_pop_fields"],
	stddev_samp?:ValueTypes["objects_stddev_samp_fields"],
	sum?:ValueTypes["objects_sum_fields"],
	var_pop?:ValueTypes["objects_var_pop_fields"],
	var_samp?:ValueTypes["objects_var_samp_fields"],
	variance?:ValueTypes["objects_variance_fields"],
		__typename?: true
}>;
	/** aggregate avg on columns */
["objects_avg_fields"]: AliasType<{
	id?:true,
		__typename?: true
}>;
	/** Boolean expression to filter rows from the table "objects". All fields are combined with a logical 'AND'. */
["objects_bool_exp"]: {
	_and?:ValueTypes["objects_bool_exp"][],
	_not?:ValueTypes["objects_bool_exp"],
	_or?:ValueTypes["objects_bool_exp"][],
	id?:ValueTypes["Int_comparison_exp"],
	name?:ValueTypes["String_comparison_exp"],
	object_type?:ValueTypes["String_comparison_exp"]
};
	/** unique or primary key constraints on table "objects" */
["objects_constraint"]:objects_constraint;
	/** input type for incrementing numeric columns in table "objects" */
["objects_inc_input"]: {
	id?:number
};
	/** input type for inserting data into table "objects" */
["objects_insert_input"]: {
	id?:number,
	name?:string,
	object_type?:string
};
	/** aggregate max on columns */
["objects_max_fields"]: AliasType<{
	id?:true,
	name?:true,
	object_type?:true,
		__typename?: true
}>;
	/** aggregate min on columns */
["objects_min_fields"]: AliasType<{
	id?:true,
	name?:true,
	object_type?:true,
		__typename?: true
}>;
	/** response of any mutation on the table "objects" */
["objects_mutation_response"]: AliasType<{
	/** number of rows affected by the mutation */
	affected_rows?:true,
	/** data from the rows affected by the mutation */
	returning?:ValueTypes["objects"],
		__typename?: true
}>;
	/** on_conflict condition type for table "objects" */
["objects_on_conflict"]: {
	constraint:ValueTypes["objects_constraint"],
	update_columns:ValueTypes["objects_update_column"][],
	where?:ValueTypes["objects_bool_exp"]
};
	/** Ordering options when selecting data from "objects". */
["objects_order_by"]: {
	id?:ValueTypes["order_by"],
	name?:ValueTypes["order_by"],
	object_type?:ValueTypes["order_by"]
};
	/** primary key columns input for table: objects */
["objects_pk_columns_input"]: {
	id:number
};
	/** select columns of table "objects" */
["objects_select_column"]:objects_select_column;
	/** input type for updating data in table "objects" */
["objects_set_input"]: {
	id?:number,
	name?:string,
	object_type?:string
};
	/** aggregate stddev on columns */
["objects_stddev_fields"]: AliasType<{
	id?:true,
		__typename?: true
}>;
	/** aggregate stddev_pop on columns */
["objects_stddev_pop_fields"]: AliasType<{
	id?:true,
		__typename?: true
}>;
	/** aggregate stddev_samp on columns */
["objects_stddev_samp_fields"]: AliasType<{
	id?:true,
		__typename?: true
}>;
	/** Streaming cursor of the table "objects" */
["objects_stream_cursor_input"]: {
	/** Stream column input with initial value */
	initial_value:ValueTypes["objects_stream_cursor_value_input"],
	/** cursor ordering */
	ordering?:ValueTypes["cursor_ordering"]
};
	/** Initial value of the column from where the streaming should start */
["objects_stream_cursor_value_input"]: {
	id?:number,
	name?:string,
	object_type?:string
};
	/** aggregate sum on columns */
["objects_sum_fields"]: AliasType<{
	id?:true,
		__typename?: true
}>;
	/** update columns of table "objects" */
["objects_update_column"]:objects_update_column;
	["objects_updates"]: {
	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["objects_inc_input"],
	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["objects_set_input"],
	/** filter the rows which have to be updated */
	where:ValueTypes["objects_bool_exp"]
};
	/** aggregate var_pop on columns */
["objects_var_pop_fields"]: AliasType<{
	id?:true,
		__typename?: true
}>;
	/** aggregate var_samp on columns */
["objects_var_samp_fields"]: AliasType<{
	id?:true,
		__typename?: true
}>;
	/** aggregate variance on columns */
["objects_variance_fields"]: AliasType<{
	id?:true,
		__typename?: true
}>;
	/** column ordering options */
["order_by"]:order_by;
	["query_root"]: AliasType<{
associations?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["associations_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["associations_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["associations_bool_exp"]},ValueTypes["associations"]],
associations_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["associations_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["associations_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["associations_bool_exp"]},ValueTypes["associations_aggregate"]],
associations_by_pk?: [{	id:number},ValueTypes["associations"]],
closest_user_location?: [{	/** input parameters for function "closest_user_location" */
	args:ValueTypes["closest_user_location_args"],	/** distinct select on columns */
	distinct_on?:ValueTypes["locations_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["locations_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["locations_bool_exp"]},ValueTypes["locations"]],
closest_user_location_aggregate?: [{	/** input parameters for function "closest_user_location_aggregate" */
	args:ValueTypes["closest_user_location_args"],	/** distinct select on columns */
	distinct_on?:ValueTypes["locations_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["locations_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["locations_bool_exp"]},ValueTypes["locations_aggregate"]],
event_tag?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["event_tag_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["event_tag_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["event_tag_bool_exp"]},ValueTypes["event_tag"]],
event_tag_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["event_tag_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["event_tag_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["event_tag_bool_exp"]},ValueTypes["event_tag_aggregate"]],
event_tag_by_pk?: [{	event_id:number,	tag_name:string},ValueTypes["event_tag"]],
event_types?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["event_types_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["event_types_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["event_types_bool_exp"]},ValueTypes["event_types"]],
event_types_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["event_types_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["event_types_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["event_types_bool_exp"]},ValueTypes["event_types_aggregate"]],
event_types_by_pk?: [{	name:string},ValueTypes["event_types"]],
events?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["events_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["events_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["events_bool_exp"]},ValueTypes["events"]],
events_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["events_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["events_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["events_bool_exp"]},ValueTypes["events_aggregate"]],
events_by_pk?: [{	id:number},ValueTypes["events"]],
fetch_associations?: [{	/** input parameters for function "fetch_associations" */
	args:ValueTypes["fetch_associations_args"],	/** distinct select on columns */
	distinct_on?:ValueTypes["associations_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["associations_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["associations_bool_exp"]},ValueTypes["associations"]],
fetch_associations_aggregate?: [{	/** input parameters for function "fetch_associations_aggregate" */
	args:ValueTypes["fetch_associations_args"],	/** distinct select on columns */
	distinct_on?:ValueTypes["associations_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["associations_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["associations_bool_exp"]},ValueTypes["associations_aggregate"]],
goals?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["goals_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["goals_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["goals_bool_exp"]},ValueTypes["goals"]],
goals_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["goals_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["goals_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["goals_bool_exp"]},ValueTypes["goals_aggregate"]],
goals_by_pk?: [{	id:number},ValueTypes["goals"]],
interactions?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["interactions_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["interactions_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["interactions_bool_exp"]},ValueTypes["interactions"]],
interactions_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["interactions_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["interactions_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["interactions_bool_exp"]},ValueTypes["interactions_aggregate"]],
interactions_by_pk?: [{	id:number},ValueTypes["interactions"]],
locations?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["locations_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["locations_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["locations_bool_exp"]},ValueTypes["locations"]],
locations_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["locations_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["locations_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["locations_bool_exp"]},ValueTypes["locations_aggregate"]],
locations_by_pk?: [{	id:number},ValueTypes["locations"]],
match_interactions?: [{	/** input parameters for function "match_interactions" */
	args:ValueTypes["match_interactions_args"],	/** distinct select on columns */
	distinct_on?:ValueTypes["interactions_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["interactions_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["interactions_bool_exp"]},ValueTypes["interactions"]],
match_interactions_aggregate?: [{	/** input parameters for function "match_interactions_aggregate" */
	args:ValueTypes["match_interactions_args"],	/** distinct select on columns */
	distinct_on?:ValueTypes["interactions_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["interactions_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["interactions_bool_exp"]},ValueTypes["interactions_aggregate"]],
object_types?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["object_types_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["object_types_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["object_types_bool_exp"]},ValueTypes["object_types"]],
object_types_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["object_types_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["object_types_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["object_types_bool_exp"]},ValueTypes["object_types_aggregate"]],
object_types_by_pk?: [{	id:string},ValueTypes["object_types"]],
objects?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["objects_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["objects_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["objects_bool_exp"]},ValueTypes["objects"]],
objects_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["objects_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["objects_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["objects_bool_exp"]},ValueTypes["objects_aggregate"]],
objects_by_pk?: [{	id:number},ValueTypes["objects"]],
todos?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["todos_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["todos_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["todos_bool_exp"]},ValueTypes["todos"]],
todos_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["todos_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["todos_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["todos_bool_exp"]},ValueTypes["todos_aggregate"]],
todos_by_pk?: [{	id:number},ValueTypes["todos"]],
users?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["users_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["users_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["users_bool_exp"]},ValueTypes["users"]],
users_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["users_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["users_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["users_bool_exp"]},ValueTypes["users_aggregate"]],
users_by_pk?: [{	id:number},ValueTypes["users"]],
		__typename?: true
}>;
	["st_d_within_geography_input"]: {
	distance:number,
	from:ValueTypes["geography"],
	use_spheroid?:boolean
};
	["st_d_within_input"]: {
	distance:number,
	from:ValueTypes["geometry"]
};
	/** Boolean expression to compare columns of type "String". All fields are combined with logical 'AND'. */
["String_comparison_exp"]: {
	_eq?:string,
	_gt?:string,
	_gte?:string,
	/** does the column match the given case-insensitive pattern */
	_ilike?:string,
	_in?:string[],
	/** does the column match the given POSIX regular expression, case insensitive */
	_iregex?:string,
	_is_null?:boolean,
	/** does the column match the given pattern */
	_like?:string,
	_lt?:string,
	_lte?:string,
	_neq?:string,
	/** does the column NOT match the given case-insensitive pattern */
	_nilike?:string,
	_nin?:string[],
	/** does the column NOT match the given POSIX regular expression, case insensitive */
	_niregex?:string,
	/** does the column NOT match the given pattern */
	_nlike?:string,
	/** does the column NOT match the given POSIX regular expression, case sensitive */
	_nregex?:string,
	/** does the column NOT match the given SQL regular expression */
	_nsimilar?:string,
	/** does the column match the given POSIX regular expression, case sensitive */
	_regex?:string,
	/** does the column match the given SQL regular expression */
	_similar?:string
};
	["subscription_root"]: AliasType<{
associations?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["associations_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["associations_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["associations_bool_exp"]},ValueTypes["associations"]],
associations_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["associations_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["associations_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["associations_bool_exp"]},ValueTypes["associations_aggregate"]],
associations_by_pk?: [{	id:number},ValueTypes["associations"]],
associations_stream?: [{	/** maximum number of rows returned in a single batch */
	batch_size:number,	/** cursor to stream the results returned by the query */
	cursor?:ValueTypes["associations_stream_cursor_input"][],	/** filter the rows returned */
	where?:ValueTypes["associations_bool_exp"]},ValueTypes["associations"]],
closest_user_location?: [{	/** input parameters for function "closest_user_location" */
	args:ValueTypes["closest_user_location_args"],	/** distinct select on columns */
	distinct_on?:ValueTypes["locations_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["locations_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["locations_bool_exp"]},ValueTypes["locations"]],
closest_user_location_aggregate?: [{	/** input parameters for function "closest_user_location_aggregate" */
	args:ValueTypes["closest_user_location_args"],	/** distinct select on columns */
	distinct_on?:ValueTypes["locations_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["locations_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["locations_bool_exp"]},ValueTypes["locations_aggregate"]],
event_tag?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["event_tag_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["event_tag_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["event_tag_bool_exp"]},ValueTypes["event_tag"]],
event_tag_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["event_tag_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["event_tag_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["event_tag_bool_exp"]},ValueTypes["event_tag_aggregate"]],
event_tag_by_pk?: [{	event_id:number,	tag_name:string},ValueTypes["event_tag"]],
event_tag_stream?: [{	/** maximum number of rows returned in a single batch */
	batch_size:number,	/** cursor to stream the results returned by the query */
	cursor?:ValueTypes["event_tag_stream_cursor_input"][],	/** filter the rows returned */
	where?:ValueTypes["event_tag_bool_exp"]},ValueTypes["event_tag"]],
event_types?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["event_types_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["event_types_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["event_types_bool_exp"]},ValueTypes["event_types"]],
event_types_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["event_types_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["event_types_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["event_types_bool_exp"]},ValueTypes["event_types_aggregate"]],
event_types_by_pk?: [{	name:string},ValueTypes["event_types"]],
event_types_stream?: [{	/** maximum number of rows returned in a single batch */
	batch_size:number,	/** cursor to stream the results returned by the query */
	cursor?:ValueTypes["event_types_stream_cursor_input"][],	/** filter the rows returned */
	where?:ValueTypes["event_types_bool_exp"]},ValueTypes["event_types"]],
events?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["events_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["events_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["events_bool_exp"]},ValueTypes["events"]],
events_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["events_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["events_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["events_bool_exp"]},ValueTypes["events_aggregate"]],
events_by_pk?: [{	id:number},ValueTypes["events"]],
events_stream?: [{	/** maximum number of rows returned in a single batch */
	batch_size:number,	/** cursor to stream the results returned by the query */
	cursor?:ValueTypes["events_stream_cursor_input"][],	/** filter the rows returned */
	where?:ValueTypes["events_bool_exp"]},ValueTypes["events"]],
fetch_associations?: [{	/** input parameters for function "fetch_associations" */
	args:ValueTypes["fetch_associations_args"],	/** distinct select on columns */
	distinct_on?:ValueTypes["associations_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["associations_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["associations_bool_exp"]},ValueTypes["associations"]],
fetch_associations_aggregate?: [{	/** input parameters for function "fetch_associations_aggregate" */
	args:ValueTypes["fetch_associations_args"],	/** distinct select on columns */
	distinct_on?:ValueTypes["associations_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["associations_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["associations_bool_exp"]},ValueTypes["associations_aggregate"]],
goals?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["goals_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["goals_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["goals_bool_exp"]},ValueTypes["goals"]],
goals_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["goals_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["goals_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["goals_bool_exp"]},ValueTypes["goals_aggregate"]],
goals_by_pk?: [{	id:number},ValueTypes["goals"]],
goals_stream?: [{	/** maximum number of rows returned in a single batch */
	batch_size:number,	/** cursor to stream the results returned by the query */
	cursor?:ValueTypes["goals_stream_cursor_input"][],	/** filter the rows returned */
	where?:ValueTypes["goals_bool_exp"]},ValueTypes["goals"]],
interactions?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["interactions_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["interactions_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["interactions_bool_exp"]},ValueTypes["interactions"]],
interactions_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["interactions_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["interactions_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["interactions_bool_exp"]},ValueTypes["interactions_aggregate"]],
interactions_by_pk?: [{	id:number},ValueTypes["interactions"]],
interactions_stream?: [{	/** maximum number of rows returned in a single batch */
	batch_size:number,	/** cursor to stream the results returned by the query */
	cursor?:ValueTypes["interactions_stream_cursor_input"][],	/** filter the rows returned */
	where?:ValueTypes["interactions_bool_exp"]},ValueTypes["interactions"]],
locations?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["locations_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["locations_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["locations_bool_exp"]},ValueTypes["locations"]],
locations_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["locations_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["locations_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["locations_bool_exp"]},ValueTypes["locations_aggregate"]],
locations_by_pk?: [{	id:number},ValueTypes["locations"]],
locations_stream?: [{	/** maximum number of rows returned in a single batch */
	batch_size:number,	/** cursor to stream the results returned by the query */
	cursor?:ValueTypes["locations_stream_cursor_input"][],	/** filter the rows returned */
	where?:ValueTypes["locations_bool_exp"]},ValueTypes["locations"]],
match_interactions?: [{	/** input parameters for function "match_interactions" */
	args:ValueTypes["match_interactions_args"],	/** distinct select on columns */
	distinct_on?:ValueTypes["interactions_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["interactions_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["interactions_bool_exp"]},ValueTypes["interactions"]],
match_interactions_aggregate?: [{	/** input parameters for function "match_interactions_aggregate" */
	args:ValueTypes["match_interactions_args"],	/** distinct select on columns */
	distinct_on?:ValueTypes["interactions_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["interactions_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["interactions_bool_exp"]},ValueTypes["interactions_aggregate"]],
object_types?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["object_types_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["object_types_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["object_types_bool_exp"]},ValueTypes["object_types"]],
object_types_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["object_types_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["object_types_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["object_types_bool_exp"]},ValueTypes["object_types_aggregate"]],
object_types_by_pk?: [{	id:string},ValueTypes["object_types"]],
object_types_stream?: [{	/** maximum number of rows returned in a single batch */
	batch_size:number,	/** cursor to stream the results returned by the query */
	cursor?:ValueTypes["object_types_stream_cursor_input"][],	/** filter the rows returned */
	where?:ValueTypes["object_types_bool_exp"]},ValueTypes["object_types"]],
objects?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["objects_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["objects_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["objects_bool_exp"]},ValueTypes["objects"]],
objects_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["objects_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["objects_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["objects_bool_exp"]},ValueTypes["objects_aggregate"]],
objects_by_pk?: [{	id:number},ValueTypes["objects"]],
objects_stream?: [{	/** maximum number of rows returned in a single batch */
	batch_size:number,	/** cursor to stream the results returned by the query */
	cursor?:ValueTypes["objects_stream_cursor_input"][],	/** filter the rows returned */
	where?:ValueTypes["objects_bool_exp"]},ValueTypes["objects"]],
todos?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["todos_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["todos_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["todos_bool_exp"]},ValueTypes["todos"]],
todos_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["todos_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["todos_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["todos_bool_exp"]},ValueTypes["todos_aggregate"]],
todos_by_pk?: [{	id:number},ValueTypes["todos"]],
todos_stream?: [{	/** maximum number of rows returned in a single batch */
	batch_size:number,	/** cursor to stream the results returned by the query */
	cursor?:ValueTypes["todos_stream_cursor_input"][],	/** filter the rows returned */
	where?:ValueTypes["todos_bool_exp"]},ValueTypes["todos"]],
users?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["users_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["users_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["users_bool_exp"]},ValueTypes["users"]],
users_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["users_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["users_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["users_bool_exp"]},ValueTypes["users_aggregate"]],
users_by_pk?: [{	id:number},ValueTypes["users"]],
users_stream?: [{	/** maximum number of rows returned in a single batch */
	batch_size:number,	/** cursor to stream the results returned by the query */
	cursor?:ValueTypes["users_stream_cursor_input"][],	/** filter the rows returned */
	where?:ValueTypes["users_bool_exp"]},ValueTypes["users"]],
		__typename?: true
}>;
	["timestamp"]:unknown;
	/** Boolean expression to compare columns of type "timestamp". All fields are combined with logical 'AND'. */
["timestamp_comparison_exp"]: {
	_eq?:ValueTypes["timestamp"],
	_gt?:ValueTypes["timestamp"],
	_gte?:ValueTypes["timestamp"],
	_in?:ValueTypes["timestamp"][],
	_is_null?:boolean,
	_lt?:ValueTypes["timestamp"],
	_lte?:ValueTypes["timestamp"],
	_neq?:ValueTypes["timestamp"],
	_nin?:ValueTypes["timestamp"][]
};
	["timestamptz"]:unknown;
	/** Boolean expression to compare columns of type "timestamptz". All fields are combined with logical 'AND'. */
["timestamptz_comparison_exp"]: {
	_eq?:ValueTypes["timestamptz"],
	_gt?:ValueTypes["timestamptz"],
	_gte?:ValueTypes["timestamptz"],
	_in?:ValueTypes["timestamptz"][],
	_is_null?:boolean,
	_lt?:ValueTypes["timestamptz"],
	_lte?:ValueTypes["timestamptz"],
	_neq?:ValueTypes["timestamptz"],
	_nin?:ValueTypes["timestamptz"][]
};
	/** columns and relationships of "todos" */
["todos"]: AliasType<{
	current_count?:true,
	done_as_expected?:true,
	due?:true,
	/** An object relationship */
	goal?:ValueTypes["goals"],
	goal_id?:true,
	id?:true,
	name?:true,
	status?:true,
	updated?:true,
	/** An object relationship */
	user?:ValueTypes["users"],
	user_id?:true,
		__typename?: true
}>;
	/** aggregated selection of "todos" */
["todos_aggregate"]: AliasType<{
	aggregate?:ValueTypes["todos_aggregate_fields"],
	nodes?:ValueTypes["todos"],
		__typename?: true
}>;
	/** aggregate fields of "todos" */
["todos_aggregate_fields"]: AliasType<{
	avg?:ValueTypes["todos_avg_fields"],
count?: [{	columns?:ValueTypes["todos_select_column"][],	distinct?:boolean},true],
	max?:ValueTypes["todos_max_fields"],
	min?:ValueTypes["todos_min_fields"],
	stddev?:ValueTypes["todos_stddev_fields"],
	stddev_pop?:ValueTypes["todos_stddev_pop_fields"],
	stddev_samp?:ValueTypes["todos_stddev_samp_fields"],
	sum?:ValueTypes["todos_sum_fields"],
	var_pop?:ValueTypes["todos_var_pop_fields"],
	var_samp?:ValueTypes["todos_var_samp_fields"],
	variance?:ValueTypes["todos_variance_fields"],
		__typename?: true
}>;
	/** aggregate avg on columns */
["todos_avg_fields"]: AliasType<{
	current_count?:true,
	goal_id?:true,
	id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** Boolean expression to filter rows from the table "todos". All fields are combined with a logical 'AND'. */
["todos_bool_exp"]: {
	_and?:ValueTypes["todos_bool_exp"][],
	_not?:ValueTypes["todos_bool_exp"],
	_or?:ValueTypes["todos_bool_exp"][],
	current_count?:ValueTypes["Int_comparison_exp"],
	done_as_expected?:ValueTypes["Boolean_comparison_exp"],
	due?:ValueTypes["timestamptz_comparison_exp"],
	goal?:ValueTypes["goals_bool_exp"],
	goal_id?:ValueTypes["Int_comparison_exp"],
	id?:ValueTypes["Int_comparison_exp"],
	name?:ValueTypes["String_comparison_exp"],
	status?:ValueTypes["String_comparison_exp"],
	updated?:ValueTypes["timestamptz_comparison_exp"],
	user?:ValueTypes["users_bool_exp"],
	user_id?:ValueTypes["Int_comparison_exp"]
};
	/** unique or primary key constraints on table "todos" */
["todos_constraint"]:todos_constraint;
	/** input type for incrementing numeric columns in table "todos" */
["todos_inc_input"]: {
	current_count?:number,
	goal_id?:number,
	id?:number,
	user_id?:number
};
	/** input type for inserting data into table "todos" */
["todos_insert_input"]: {
	current_count?:number,
	done_as_expected?:boolean,
	due?:ValueTypes["timestamptz"],
	goal?:ValueTypes["goals_obj_rel_insert_input"],
	goal_id?:number,
	id?:number,
	name?:string,
	status?:string,
	updated?:ValueTypes["timestamptz"],
	user?:ValueTypes["users_obj_rel_insert_input"],
	user_id?:number
};
	/** aggregate max on columns */
["todos_max_fields"]: AliasType<{
	current_count?:true,
	due?:true,
	goal_id?:true,
	id?:true,
	name?:true,
	status?:true,
	updated?:true,
	user_id?:true,
		__typename?: true
}>;
	/** aggregate min on columns */
["todos_min_fields"]: AliasType<{
	current_count?:true,
	due?:true,
	goal_id?:true,
	id?:true,
	name?:true,
	status?:true,
	updated?:true,
	user_id?:true,
		__typename?: true
}>;
	/** response of any mutation on the table "todos" */
["todos_mutation_response"]: AliasType<{
	/** number of rows affected by the mutation */
	affected_rows?:true,
	/** data from the rows affected by the mutation */
	returning?:ValueTypes["todos"],
		__typename?: true
}>;
	/** input type for inserting object relation for remote table "todos" */
["todos_obj_rel_insert_input"]: {
	data:ValueTypes["todos_insert_input"],
	/** upsert condition */
	on_conflict?:ValueTypes["todos_on_conflict"]
};
	/** on_conflict condition type for table "todos" */
["todos_on_conflict"]: {
	constraint:ValueTypes["todos_constraint"],
	update_columns:ValueTypes["todos_update_column"][],
	where?:ValueTypes["todos_bool_exp"]
};
	/** Ordering options when selecting data from "todos". */
["todos_order_by"]: {
	current_count?:ValueTypes["order_by"],
	done_as_expected?:ValueTypes["order_by"],
	due?:ValueTypes["order_by"],
	goal?:ValueTypes["goals_order_by"],
	goal_id?:ValueTypes["order_by"],
	id?:ValueTypes["order_by"],
	name?:ValueTypes["order_by"],
	status?:ValueTypes["order_by"],
	updated?:ValueTypes["order_by"],
	user?:ValueTypes["users_order_by"],
	user_id?:ValueTypes["order_by"]
};
	/** primary key columns input for table: todos */
["todos_pk_columns_input"]: {
	id:number
};
	/** select columns of table "todos" */
["todos_select_column"]:todos_select_column;
	/** input type for updating data in table "todos" */
["todos_set_input"]: {
	current_count?:number,
	done_as_expected?:boolean,
	due?:ValueTypes["timestamptz"],
	goal_id?:number,
	id?:number,
	name?:string,
	status?:string,
	updated?:ValueTypes["timestamptz"],
	user_id?:number
};
	/** aggregate stddev on columns */
["todos_stddev_fields"]: AliasType<{
	current_count?:true,
	goal_id?:true,
	id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** aggregate stddev_pop on columns */
["todos_stddev_pop_fields"]: AliasType<{
	current_count?:true,
	goal_id?:true,
	id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** aggregate stddev_samp on columns */
["todos_stddev_samp_fields"]: AliasType<{
	current_count?:true,
	goal_id?:true,
	id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** Streaming cursor of the table "todos" */
["todos_stream_cursor_input"]: {
	/** Stream column input with initial value */
	initial_value:ValueTypes["todos_stream_cursor_value_input"],
	/** cursor ordering */
	ordering?:ValueTypes["cursor_ordering"]
};
	/** Initial value of the column from where the streaming should start */
["todos_stream_cursor_value_input"]: {
	current_count?:number,
	done_as_expected?:boolean,
	due?:ValueTypes["timestamptz"],
	goal_id?:number,
	id?:number,
	name?:string,
	status?:string,
	updated?:ValueTypes["timestamptz"],
	user_id?:number
};
	/** aggregate sum on columns */
["todos_sum_fields"]: AliasType<{
	current_count?:true,
	goal_id?:true,
	id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** update columns of table "todos" */
["todos_update_column"]:todos_update_column;
	["todos_updates"]: {
	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["todos_inc_input"],
	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["todos_set_input"],
	/** filter the rows which have to be updated */
	where:ValueTypes["todos_bool_exp"]
};
	/** aggregate var_pop on columns */
["todos_var_pop_fields"]: AliasType<{
	current_count?:true,
	goal_id?:true,
	id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** aggregate var_samp on columns */
["todos_var_samp_fields"]: AliasType<{
	current_count?:true,
	goal_id?:true,
	id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** aggregate variance on columns */
["todos_variance_fields"]: AliasType<{
	current_count?:true,
	goal_id?:true,
	id?:true,
	user_id?:true,
		__typename?: true
}>;
	/** columns and relationships of "users" */
["users"]: AliasType<{
	apple_id?:true,
closest_user_location?: [{	/** input parameters for computed field "closest_user_location" defined on table "users" */
	args:ValueTypes["closest_user_location_users_args"],	/** distinct select on columns */
	distinct_on?:ValueTypes["locations_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["locations_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["locations_bool_exp"]},ValueTypes["locations"]],
config?: [{	/** JSON select path */
	path?:string},true],
events?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["events_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["events_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["events_bool_exp"]},ValueTypes["events"]],
events_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["events_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["events_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["events_bool_exp"]},ValueTypes["events_aggregate"]],
	id?:true,
	language?:true,
locations?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["locations_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["locations_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["locations_bool_exp"]},ValueTypes["locations"]],
locations_aggregate?: [{	/** distinct select on columns */
	distinct_on?:ValueTypes["locations_select_column"][],	/** limit the number of rows returned */
	limit?:number,	/** skip the first n rows. Use only with order_by */
	offset?:number,	/** sort the rows by one or more columns */
	order_by?:ValueTypes["locations_order_by"][],	/** filter the rows returned */
	where?:ValueTypes["locations_bool_exp"]},ValueTypes["locations_aggregate"]],
	name?:true,
	timezone?:true,
		__typename?: true
}>;
	/** aggregated selection of "users" */
["users_aggregate"]: AliasType<{
	aggregate?:ValueTypes["users_aggregate_fields"],
	nodes?:ValueTypes["users"],
		__typename?: true
}>;
	/** aggregate fields of "users" */
["users_aggregate_fields"]: AliasType<{
	avg?:ValueTypes["users_avg_fields"],
count?: [{	columns?:ValueTypes["users_select_column"][],	distinct?:boolean},true],
	max?:ValueTypes["users_max_fields"],
	min?:ValueTypes["users_min_fields"],
	stddev?:ValueTypes["users_stddev_fields"],
	stddev_pop?:ValueTypes["users_stddev_pop_fields"],
	stddev_samp?:ValueTypes["users_stddev_samp_fields"],
	sum?:ValueTypes["users_sum_fields"],
	var_pop?:ValueTypes["users_var_pop_fields"],
	var_samp?:ValueTypes["users_var_samp_fields"],
	variance?:ValueTypes["users_variance_fields"],
		__typename?: true
}>;
	/** append existing jsonb value of filtered columns with new jsonb value */
["users_append_input"]: {
	config?:ValueTypes["jsonb"]
};
	/** aggregate avg on columns */
["users_avg_fields"]: AliasType<{
	id?:true,
		__typename?: true
}>;
	/** Boolean expression to filter rows from the table "users". All fields are combined with a logical 'AND'. */
["users_bool_exp"]: {
	_and?:ValueTypes["users_bool_exp"][],
	_not?:ValueTypes["users_bool_exp"],
	_or?:ValueTypes["users_bool_exp"][],
	apple_id?:ValueTypes["String_comparison_exp"],
	config?:ValueTypes["jsonb_comparison_exp"],
	events?:ValueTypes["events_bool_exp"],
	events_aggregate?:ValueTypes["events_aggregate_bool_exp"],
	id?:ValueTypes["Int_comparison_exp"],
	language?:ValueTypes["String_comparison_exp"],
	locations?:ValueTypes["locations_bool_exp"],
	locations_aggregate?:ValueTypes["locations_aggregate_bool_exp"],
	name?:ValueTypes["String_comparison_exp"],
	timezone?:ValueTypes["String_comparison_exp"]
};
	/** unique or primary key constraints on table "users" */
["users_constraint"]:users_constraint;
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
["users_delete_at_path_input"]: {
	config?:string[]
};
	/** delete the array element with specified index (negative integers count from the
end). throws an error if top level container is not an array */
["users_delete_elem_input"]: {
	config?:number
};
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
["users_delete_key_input"]: {
	config?:string
};
	/** input type for incrementing numeric columns in table "users" */
["users_inc_input"]: {
	id?:number
};
	/** input type for inserting data into table "users" */
["users_insert_input"]: {
	apple_id?:string,
	config?:ValueTypes["jsonb"],
	events?:ValueTypes["events_arr_rel_insert_input"],
	id?:number,
	language?:string,
	locations?:ValueTypes["locations_arr_rel_insert_input"],
	name?:string,
	timezone?:string
};
	/** aggregate max on columns */
["users_max_fields"]: AliasType<{
	apple_id?:true,
	id?:true,
	language?:true,
	name?:true,
	timezone?:true,
		__typename?: true
}>;
	/** aggregate min on columns */
["users_min_fields"]: AliasType<{
	apple_id?:true,
	id?:true,
	language?:true,
	name?:true,
	timezone?:true,
		__typename?: true
}>;
	/** response of any mutation on the table "users" */
["users_mutation_response"]: AliasType<{
	/** number of rows affected by the mutation */
	affected_rows?:true,
	/** data from the rows affected by the mutation */
	returning?:ValueTypes["users"],
		__typename?: true
}>;
	/** input type for inserting object relation for remote table "users" */
["users_obj_rel_insert_input"]: {
	data:ValueTypes["users_insert_input"],
	/** upsert condition */
	on_conflict?:ValueTypes["users_on_conflict"]
};
	/** on_conflict condition type for table "users" */
["users_on_conflict"]: {
	constraint:ValueTypes["users_constraint"],
	update_columns:ValueTypes["users_update_column"][],
	where?:ValueTypes["users_bool_exp"]
};
	/** Ordering options when selecting data from "users". */
["users_order_by"]: {
	apple_id?:ValueTypes["order_by"],
	config?:ValueTypes["order_by"],
	events_aggregate?:ValueTypes["events_aggregate_order_by"],
	id?:ValueTypes["order_by"],
	language?:ValueTypes["order_by"],
	locations_aggregate?:ValueTypes["locations_aggregate_order_by"],
	name?:ValueTypes["order_by"],
	timezone?:ValueTypes["order_by"]
};
	/** primary key columns input for table: users */
["users_pk_columns_input"]: {
	id:number
};
	/** prepend existing jsonb value of filtered columns with new jsonb value */
["users_prepend_input"]: {
	config?:ValueTypes["jsonb"]
};
	["users_scalar"]:unknown;
	/** select columns of table "users" */
["users_select_column"]:users_select_column;
	/** input type for updating data in table "users" */
["users_set_input"]: {
	apple_id?:string,
	config?:ValueTypes["jsonb"],
	id?:number,
	language?:string,
	name?:string,
	timezone?:string
};
	/** aggregate stddev on columns */
["users_stddev_fields"]: AliasType<{
	id?:true,
		__typename?: true
}>;
	/** aggregate stddev_pop on columns */
["users_stddev_pop_fields"]: AliasType<{
	id?:true,
		__typename?: true
}>;
	/** aggregate stddev_samp on columns */
["users_stddev_samp_fields"]: AliasType<{
	id?:true,
		__typename?: true
}>;
	/** Streaming cursor of the table "users" */
["users_stream_cursor_input"]: {
	/** Stream column input with initial value */
	initial_value:ValueTypes["users_stream_cursor_value_input"],
	/** cursor ordering */
	ordering?:ValueTypes["cursor_ordering"]
};
	/** Initial value of the column from where the streaming should start */
["users_stream_cursor_value_input"]: {
	apple_id?:string,
	config?:ValueTypes["jsonb"],
	id?:number,
	language?:string,
	name?:string,
	timezone?:string
};
	/** aggregate sum on columns */
["users_sum_fields"]: AliasType<{
	id?:true,
		__typename?: true
}>;
	/** update columns of table "users" */
["users_update_column"]:users_update_column;
	["users_updates"]: {
	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:ValueTypes["users_append_input"],
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:ValueTypes["users_delete_at_path_input"],
	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:ValueTypes["users_delete_elem_input"],
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:ValueTypes["users_delete_key_input"],
	/** increments the numeric columns with given value of the filtered values */
	_inc?:ValueTypes["users_inc_input"],
	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:ValueTypes["users_prepend_input"],
	/** sets the columns of the filtered rows to the given values */
	_set?:ValueTypes["users_set_input"],
	/** filter the rows which have to be updated */
	where:ValueTypes["users_bool_exp"]
};
	/** aggregate var_pop on columns */
["users_var_pop_fields"]: AliasType<{
	id?:true,
		__typename?: true
}>;
	/** aggregate var_samp on columns */
["users_var_samp_fields"]: AliasType<{
	id?:true,
		__typename?: true
}>;
	/** aggregate variance on columns */
["users_variance_fields"]: AliasType<{
	id?:true,
		__typename?: true
}>;
	["vector"]:unknown;
	/** Boolean expression to compare columns of type "vector". All fields are combined with logical 'AND'. */
["vector_comparison_exp"]: {
	_eq?:ValueTypes["vector"],
	_gt?:ValueTypes["vector"],
	_gte?:ValueTypes["vector"],
	_in?:ValueTypes["vector"][],
	_is_null?:boolean,
	_lt?:ValueTypes["vector"],
	_lte?:ValueTypes["vector"],
	_neq?:ValueTypes["vector"],
	_nin?:ValueTypes["vector"][]
}
  }

export type PartialObjects = {
    /** columns and relationships of "associations" */
["associations"]: {
		__typename?: "associations";
			id?:number,
			metadata?:PartialObjects["jsonb"],
			ref_one_id?:number,
			ref_one_table?:string,
			ref_two_id?:number,
			ref_two_table?:string
	},
	/** aggregated selection of "associations" */
["associations_aggregate"]: {
		__typename?: "associations_aggregate";
			aggregate?:PartialObjects["associations_aggregate_fields"],
			nodes?:PartialObjects["associations"][]
	},
	/** aggregate fields of "associations" */
["associations_aggregate_fields"]: {
		__typename?: "associations_aggregate_fields";
			avg?:PartialObjects["associations_avg_fields"],
			count?:number,
			max?:PartialObjects["associations_max_fields"],
			min?:PartialObjects["associations_min_fields"],
			stddev?:PartialObjects["associations_stddev_fields"],
			stddev_pop?:PartialObjects["associations_stddev_pop_fields"],
			stddev_samp?:PartialObjects["associations_stddev_samp_fields"],
			sum?:PartialObjects["associations_sum_fields"],
			var_pop?:PartialObjects["associations_var_pop_fields"],
			var_samp?:PartialObjects["associations_var_samp_fields"],
			variance?:PartialObjects["associations_variance_fields"]
	},
	/** order by aggregate values of table "associations" */
["associations_aggregate_order_by"]: {
	avg?:PartialObjects["associations_avg_order_by"],
	count?:PartialObjects["order_by"],
	max?:PartialObjects["associations_max_order_by"],
	min?:PartialObjects["associations_min_order_by"],
	stddev?:PartialObjects["associations_stddev_order_by"],
	stddev_pop?:PartialObjects["associations_stddev_pop_order_by"],
	stddev_samp?:PartialObjects["associations_stddev_samp_order_by"],
	sum?:PartialObjects["associations_sum_order_by"],
	var_pop?:PartialObjects["associations_var_pop_order_by"],
	var_samp?:PartialObjects["associations_var_samp_order_by"],
	variance?:PartialObjects["associations_variance_order_by"]
},
	/** append existing jsonb value of filtered columns with new jsonb value */
["associations_append_input"]: {
	metadata?:PartialObjects["jsonb"]
},
	/** aggregate avg on columns */
["associations_avg_fields"]: {
		__typename?: "associations_avg_fields";
			id?:number,
			ref_one_id?:number,
			ref_two_id?:number
	},
	/** order by avg() on columns of table "associations" */
["associations_avg_order_by"]: {
	id?:PartialObjects["order_by"],
	ref_one_id?:PartialObjects["order_by"],
	ref_two_id?:PartialObjects["order_by"]
},
	/** Boolean expression to filter rows from the table "associations". All fields are combined with a logical 'AND'. */
["associations_bool_exp"]: {
	_and?:PartialObjects["associations_bool_exp"][],
	_not?:PartialObjects["associations_bool_exp"],
	_or?:PartialObjects["associations_bool_exp"][],
	id?:PartialObjects["Int_comparison_exp"],
	metadata?:PartialObjects["jsonb_comparison_exp"],
	ref_one_id?:PartialObjects["Int_comparison_exp"],
	ref_one_table?:PartialObjects["String_comparison_exp"],
	ref_two_id?:PartialObjects["Int_comparison_exp"],
	ref_two_table?:PartialObjects["String_comparison_exp"]
},
	/** unique or primary key constraints on table "associations" */
["associations_constraint"]:associations_constraint,
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
["associations_delete_at_path_input"]: {
	metadata?:string[]
},
	/** delete the array element with specified index (negative integers count from the
end). throws an error if top level container is not an array */
["associations_delete_elem_input"]: {
	metadata?:number
},
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
["associations_delete_key_input"]: {
	metadata?:string
},
	/** input type for incrementing numeric columns in table "associations" */
["associations_inc_input"]: {
	id?:number,
	ref_one_id?:number,
	ref_two_id?:number
},
	/** input type for inserting data into table "associations" */
["associations_insert_input"]: {
	id?:number,
	metadata?:PartialObjects["jsonb"],
	ref_one_id?:number,
	ref_one_table?:string,
	ref_two_id?:number,
	ref_two_table?:string
},
	/** aggregate max on columns */
["associations_max_fields"]: {
		__typename?: "associations_max_fields";
			id?:number,
			ref_one_id?:number,
			ref_one_table?:string,
			ref_two_id?:number,
			ref_two_table?:string
	},
	/** order by max() on columns of table "associations" */
["associations_max_order_by"]: {
	id?:PartialObjects["order_by"],
	ref_one_id?:PartialObjects["order_by"],
	ref_one_table?:PartialObjects["order_by"],
	ref_two_id?:PartialObjects["order_by"],
	ref_two_table?:PartialObjects["order_by"]
},
	/** aggregate min on columns */
["associations_min_fields"]: {
		__typename?: "associations_min_fields";
			id?:number,
			ref_one_id?:number,
			ref_one_table?:string,
			ref_two_id?:number,
			ref_two_table?:string
	},
	/** order by min() on columns of table "associations" */
["associations_min_order_by"]: {
	id?:PartialObjects["order_by"],
	ref_one_id?:PartialObjects["order_by"],
	ref_one_table?:PartialObjects["order_by"],
	ref_two_id?:PartialObjects["order_by"],
	ref_two_table?:PartialObjects["order_by"]
},
	/** response of any mutation on the table "associations" */
["associations_mutation_response"]: {
		__typename?: "associations_mutation_response";
			/** number of rows affected by the mutation */
	affected_rows?:number,
			/** data from the rows affected by the mutation */
	returning?:PartialObjects["associations"][]
	},
	/** on_conflict condition type for table "associations" */
["associations_on_conflict"]: {
	constraint:PartialObjects["associations_constraint"],
	update_columns:PartialObjects["associations_update_column"][],
	where?:PartialObjects["associations_bool_exp"]
},
	/** Ordering options when selecting data from "associations". */
["associations_order_by"]: {
	id?:PartialObjects["order_by"],
	metadata?:PartialObjects["order_by"],
	ref_one_id?:PartialObjects["order_by"],
	ref_one_table?:PartialObjects["order_by"],
	ref_two_id?:PartialObjects["order_by"],
	ref_two_table?:PartialObjects["order_by"]
},
	/** primary key columns input for table: associations */
["associations_pk_columns_input"]: {
	id:number
},
	/** prepend existing jsonb value of filtered columns with new jsonb value */
["associations_prepend_input"]: {
	metadata?:PartialObjects["jsonb"]
},
	/** select columns of table "associations" */
["associations_select_column"]:associations_select_column,
	/** input type for updating data in table "associations" */
["associations_set_input"]: {
	id?:number,
	metadata?:PartialObjects["jsonb"],
	ref_one_id?:number,
	ref_one_table?:string,
	ref_two_id?:number,
	ref_two_table?:string
},
	/** aggregate stddev on columns */
["associations_stddev_fields"]: {
		__typename?: "associations_stddev_fields";
			id?:number,
			ref_one_id?:number,
			ref_two_id?:number
	},
	/** order by stddev() on columns of table "associations" */
["associations_stddev_order_by"]: {
	id?:PartialObjects["order_by"],
	ref_one_id?:PartialObjects["order_by"],
	ref_two_id?:PartialObjects["order_by"]
},
	/** aggregate stddev_pop on columns */
["associations_stddev_pop_fields"]: {
		__typename?: "associations_stddev_pop_fields";
			id?:number,
			ref_one_id?:number,
			ref_two_id?:number
	},
	/** order by stddev_pop() on columns of table "associations" */
["associations_stddev_pop_order_by"]: {
	id?:PartialObjects["order_by"],
	ref_one_id?:PartialObjects["order_by"],
	ref_two_id?:PartialObjects["order_by"]
},
	/** aggregate stddev_samp on columns */
["associations_stddev_samp_fields"]: {
		__typename?: "associations_stddev_samp_fields";
			id?:number,
			ref_one_id?:number,
			ref_two_id?:number
	},
	/** order by stddev_samp() on columns of table "associations" */
["associations_stddev_samp_order_by"]: {
	id?:PartialObjects["order_by"],
	ref_one_id?:PartialObjects["order_by"],
	ref_two_id?:PartialObjects["order_by"]
},
	/** Streaming cursor of the table "associations" */
["associations_stream_cursor_input"]: {
	/** Stream column input with initial value */
	initial_value:PartialObjects["associations_stream_cursor_value_input"],
	/** cursor ordering */
	ordering?:PartialObjects["cursor_ordering"]
},
	/** Initial value of the column from where the streaming should start */
["associations_stream_cursor_value_input"]: {
	id?:number,
	metadata?:PartialObjects["jsonb"],
	ref_one_id?:number,
	ref_one_table?:string,
	ref_two_id?:number,
	ref_two_table?:string
},
	/** aggregate sum on columns */
["associations_sum_fields"]: {
		__typename?: "associations_sum_fields";
			id?:number,
			ref_one_id?:number,
			ref_two_id?:number
	},
	/** order by sum() on columns of table "associations" */
["associations_sum_order_by"]: {
	id?:PartialObjects["order_by"],
	ref_one_id?:PartialObjects["order_by"],
	ref_two_id?:PartialObjects["order_by"]
},
	/** update columns of table "associations" */
["associations_update_column"]:associations_update_column,
	["associations_updates"]: {
	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:PartialObjects["associations_append_input"],
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:PartialObjects["associations_delete_at_path_input"],
	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:PartialObjects["associations_delete_elem_input"],
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:PartialObjects["associations_delete_key_input"],
	/** increments the numeric columns with given value of the filtered values */
	_inc?:PartialObjects["associations_inc_input"],
	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:PartialObjects["associations_prepend_input"],
	/** sets the columns of the filtered rows to the given values */
	_set?:PartialObjects["associations_set_input"],
	/** filter the rows which have to be updated */
	where:PartialObjects["associations_bool_exp"]
},
	/** aggregate var_pop on columns */
["associations_var_pop_fields"]: {
		__typename?: "associations_var_pop_fields";
			id?:number,
			ref_one_id?:number,
			ref_two_id?:number
	},
	/** order by var_pop() on columns of table "associations" */
["associations_var_pop_order_by"]: {
	id?:PartialObjects["order_by"],
	ref_one_id?:PartialObjects["order_by"],
	ref_two_id?:PartialObjects["order_by"]
},
	/** aggregate var_samp on columns */
["associations_var_samp_fields"]: {
		__typename?: "associations_var_samp_fields";
			id?:number,
			ref_one_id?:number,
			ref_two_id?:number
	},
	/** order by var_samp() on columns of table "associations" */
["associations_var_samp_order_by"]: {
	id?:PartialObjects["order_by"],
	ref_one_id?:PartialObjects["order_by"],
	ref_two_id?:PartialObjects["order_by"]
},
	/** aggregate variance on columns */
["associations_variance_fields"]: {
		__typename?: "associations_variance_fields";
			id?:number,
			ref_one_id?:number,
			ref_two_id?:number
	},
	/** order by variance() on columns of table "associations" */
["associations_variance_order_by"]: {
	id?:PartialObjects["order_by"],
	ref_one_id?:PartialObjects["order_by"],
	ref_two_id?:PartialObjects["order_by"]
},
	/** Boolean expression to compare columns of type "Boolean". All fields are combined with logical 'AND'. */
["Boolean_comparison_exp"]: {
	_eq?:boolean,
	_gt?:boolean,
	_gte?:boolean,
	_in?:boolean[],
	_is_null?:boolean,
	_lt?:boolean,
	_lte?:boolean,
	_neq?:boolean,
	_nin?:boolean[]
},
	["closest_user_location_args"]: {
	radius?:PartialObjects["float8"],
	ref_point?:string,
	user_row?:PartialObjects["users_scalar"]
},
	["closest_user_location_users_args"]: {
	radius?:PartialObjects["float8"],
	ref_point?:string
},
	/** ordering argument of a cursor */
["cursor_ordering"]:cursor_ordering,
	/** columns and relationships of "event_tag" */
["event_tag"]: {
		__typename?: "event_tag";
			/** An object relationship */
	event?:PartialObjects["events"],
			event_id?:number,
			tag_name?:string
	},
	/** aggregated selection of "event_tag" */
["event_tag_aggregate"]: {
		__typename?: "event_tag_aggregate";
			aggregate?:PartialObjects["event_tag_aggregate_fields"],
			nodes?:PartialObjects["event_tag"][]
	},
	["event_tag_aggregate_bool_exp"]: {
	count?:PartialObjects["event_tag_aggregate_bool_exp_count"]
},
	["event_tag_aggregate_bool_exp_count"]: {
	arguments?:PartialObjects["event_tag_select_column"][],
	distinct?:boolean,
	filter?:PartialObjects["event_tag_bool_exp"],
	predicate:PartialObjects["Int_comparison_exp"]
},
	/** aggregate fields of "event_tag" */
["event_tag_aggregate_fields"]: {
		__typename?: "event_tag_aggregate_fields";
			avg?:PartialObjects["event_tag_avg_fields"],
			count?:number,
			max?:PartialObjects["event_tag_max_fields"],
			min?:PartialObjects["event_tag_min_fields"],
			stddev?:PartialObjects["event_tag_stddev_fields"],
			stddev_pop?:PartialObjects["event_tag_stddev_pop_fields"],
			stddev_samp?:PartialObjects["event_tag_stddev_samp_fields"],
			sum?:PartialObjects["event_tag_sum_fields"],
			var_pop?:PartialObjects["event_tag_var_pop_fields"],
			var_samp?:PartialObjects["event_tag_var_samp_fields"],
			variance?:PartialObjects["event_tag_variance_fields"]
	},
	/** order by aggregate values of table "event_tag" */
["event_tag_aggregate_order_by"]: {
	avg?:PartialObjects["event_tag_avg_order_by"],
	count?:PartialObjects["order_by"],
	max?:PartialObjects["event_tag_max_order_by"],
	min?:PartialObjects["event_tag_min_order_by"],
	stddev?:PartialObjects["event_tag_stddev_order_by"],
	stddev_pop?:PartialObjects["event_tag_stddev_pop_order_by"],
	stddev_samp?:PartialObjects["event_tag_stddev_samp_order_by"],
	sum?:PartialObjects["event_tag_sum_order_by"],
	var_pop?:PartialObjects["event_tag_var_pop_order_by"],
	var_samp?:PartialObjects["event_tag_var_samp_order_by"],
	variance?:PartialObjects["event_tag_variance_order_by"]
},
	/** input type for inserting array relation for remote table "event_tag" */
["event_tag_arr_rel_insert_input"]: {
	data:PartialObjects["event_tag_insert_input"][],
	/** upsert condition */
	on_conflict?:PartialObjects["event_tag_on_conflict"]
},
	/** aggregate avg on columns */
["event_tag_avg_fields"]: {
		__typename?: "event_tag_avg_fields";
			event_id?:number
	},
	/** order by avg() on columns of table "event_tag" */
["event_tag_avg_order_by"]: {
	event_id?:PartialObjects["order_by"]
},
	/** Boolean expression to filter rows from the table "event_tag". All fields are combined with a logical 'AND'. */
["event_tag_bool_exp"]: {
	_and?:PartialObjects["event_tag_bool_exp"][],
	_not?:PartialObjects["event_tag_bool_exp"],
	_or?:PartialObjects["event_tag_bool_exp"][],
	event?:PartialObjects["events_bool_exp"],
	event_id?:PartialObjects["Int_comparison_exp"],
	tag_name?:PartialObjects["String_comparison_exp"]
},
	/** unique or primary key constraints on table "event_tag" */
["event_tag_constraint"]:event_tag_constraint,
	/** input type for incrementing numeric columns in table "event_tag" */
["event_tag_inc_input"]: {
	event_id?:number
},
	/** input type for inserting data into table "event_tag" */
["event_tag_insert_input"]: {
	event?:PartialObjects["events_obj_rel_insert_input"],
	event_id?:number,
	tag_name?:string
},
	/** aggregate max on columns */
["event_tag_max_fields"]: {
		__typename?: "event_tag_max_fields";
			event_id?:number,
			tag_name?:string
	},
	/** order by max() on columns of table "event_tag" */
["event_tag_max_order_by"]: {
	event_id?:PartialObjects["order_by"],
	tag_name?:PartialObjects["order_by"]
},
	/** aggregate min on columns */
["event_tag_min_fields"]: {
		__typename?: "event_tag_min_fields";
			event_id?:number,
			tag_name?:string
	},
	/** order by min() on columns of table "event_tag" */
["event_tag_min_order_by"]: {
	event_id?:PartialObjects["order_by"],
	tag_name?:PartialObjects["order_by"]
},
	/** response of any mutation on the table "event_tag" */
["event_tag_mutation_response"]: {
		__typename?: "event_tag_mutation_response";
			/** number of rows affected by the mutation */
	affected_rows?:number,
			/** data from the rows affected by the mutation */
	returning?:PartialObjects["event_tag"][]
	},
	/** on_conflict condition type for table "event_tag" */
["event_tag_on_conflict"]: {
	constraint:PartialObjects["event_tag_constraint"],
	update_columns:PartialObjects["event_tag_update_column"][],
	where?:PartialObjects["event_tag_bool_exp"]
},
	/** Ordering options when selecting data from "event_tag". */
["event_tag_order_by"]: {
	event?:PartialObjects["events_order_by"],
	event_id?:PartialObjects["order_by"],
	tag_name?:PartialObjects["order_by"]
},
	/** primary key columns input for table: event_tag */
["event_tag_pk_columns_input"]: {
	event_id:number,
	tag_name:string
},
	/** select columns of table "event_tag" */
["event_tag_select_column"]:event_tag_select_column,
	/** input type for updating data in table "event_tag" */
["event_tag_set_input"]: {
	event_id?:number,
	tag_name?:string
},
	/** aggregate stddev on columns */
["event_tag_stddev_fields"]: {
		__typename?: "event_tag_stddev_fields";
			event_id?:number
	},
	/** order by stddev() on columns of table "event_tag" */
["event_tag_stddev_order_by"]: {
	event_id?:PartialObjects["order_by"]
},
	/** aggregate stddev_pop on columns */
["event_tag_stddev_pop_fields"]: {
		__typename?: "event_tag_stddev_pop_fields";
			event_id?:number
	},
	/** order by stddev_pop() on columns of table "event_tag" */
["event_tag_stddev_pop_order_by"]: {
	event_id?:PartialObjects["order_by"]
},
	/** aggregate stddev_samp on columns */
["event_tag_stddev_samp_fields"]: {
		__typename?: "event_tag_stddev_samp_fields";
			event_id?:number
	},
	/** order by stddev_samp() on columns of table "event_tag" */
["event_tag_stddev_samp_order_by"]: {
	event_id?:PartialObjects["order_by"]
},
	/** Streaming cursor of the table "event_tag" */
["event_tag_stream_cursor_input"]: {
	/** Stream column input with initial value */
	initial_value:PartialObjects["event_tag_stream_cursor_value_input"],
	/** cursor ordering */
	ordering?:PartialObjects["cursor_ordering"]
},
	/** Initial value of the column from where the streaming should start */
["event_tag_stream_cursor_value_input"]: {
	event_id?:number,
	tag_name?:string
},
	/** aggregate sum on columns */
["event_tag_sum_fields"]: {
		__typename?: "event_tag_sum_fields";
			event_id?:number
	},
	/** order by sum() on columns of table "event_tag" */
["event_tag_sum_order_by"]: {
	event_id?:PartialObjects["order_by"]
},
	/** update columns of table "event_tag" */
["event_tag_update_column"]:event_tag_update_column,
	["event_tag_updates"]: {
	/** increments the numeric columns with given value of the filtered values */
	_inc?:PartialObjects["event_tag_inc_input"],
	/** sets the columns of the filtered rows to the given values */
	_set?:PartialObjects["event_tag_set_input"],
	/** filter the rows which have to be updated */
	where:PartialObjects["event_tag_bool_exp"]
},
	/** aggregate var_pop on columns */
["event_tag_var_pop_fields"]: {
		__typename?: "event_tag_var_pop_fields";
			event_id?:number
	},
	/** order by var_pop() on columns of table "event_tag" */
["event_tag_var_pop_order_by"]: {
	event_id?:PartialObjects["order_by"]
},
	/** aggregate var_samp on columns */
["event_tag_var_samp_fields"]: {
		__typename?: "event_tag_var_samp_fields";
			event_id?:number
	},
	/** order by var_samp() on columns of table "event_tag" */
["event_tag_var_samp_order_by"]: {
	event_id?:PartialObjects["order_by"]
},
	/** aggregate variance on columns */
["event_tag_variance_fields"]: {
		__typename?: "event_tag_variance_fields";
			event_id?:number
	},
	/** order by variance() on columns of table "event_tag" */
["event_tag_variance_order_by"]: {
	event_id?:PartialObjects["order_by"]
},
	/** columns and relationships of "event_types" */
["event_types"]: {
		__typename?: "event_types";
			/** An array relationship */
	children?:PartialObjects["event_types"][],
			/** An aggregate relationship */
	children_aggregate?:PartialObjects["event_types_aggregate"],
			embedding?:PartialObjects["vector"],
			metadata?:PartialObjects["jsonb"],
			name?:string,
			parent?:string,
			/** A computed field, executes function "get_event_type_path" */
	parent_tree?:string
	},
	/** aggregated selection of "event_types" */
["event_types_aggregate"]: {
		__typename?: "event_types_aggregate";
			aggregate?:PartialObjects["event_types_aggregate_fields"],
			nodes?:PartialObjects["event_types"][]
	},
	["event_types_aggregate_bool_exp"]: {
	count?:PartialObjects["event_types_aggregate_bool_exp_count"]
},
	["event_types_aggregate_bool_exp_count"]: {
	arguments?:PartialObjects["event_types_select_column"][],
	distinct?:boolean,
	filter?:PartialObjects["event_types_bool_exp"],
	predicate:PartialObjects["Int_comparison_exp"]
},
	/** aggregate fields of "event_types" */
["event_types_aggregate_fields"]: {
		__typename?: "event_types_aggregate_fields";
			count?:number,
			max?:PartialObjects["event_types_max_fields"],
			min?:PartialObjects["event_types_min_fields"]
	},
	/** order by aggregate values of table "event_types" */
["event_types_aggregate_order_by"]: {
	count?:PartialObjects["order_by"],
	max?:PartialObjects["event_types_max_order_by"],
	min?:PartialObjects["event_types_min_order_by"]
},
	/** append existing jsonb value of filtered columns with new jsonb value */
["event_types_append_input"]: {
	metadata?:PartialObjects["jsonb"]
},
	/** input type for inserting array relation for remote table "event_types" */
["event_types_arr_rel_insert_input"]: {
	data:PartialObjects["event_types_insert_input"][],
	/** upsert condition */
	on_conflict?:PartialObjects["event_types_on_conflict"]
},
	/** Boolean expression to filter rows from the table "event_types". All fields are combined with a logical 'AND'. */
["event_types_bool_exp"]: {
	_and?:PartialObjects["event_types_bool_exp"][],
	_not?:PartialObjects["event_types_bool_exp"],
	_or?:PartialObjects["event_types_bool_exp"][],
	children?:PartialObjects["event_types_bool_exp"],
	children_aggregate?:PartialObjects["event_types_aggregate_bool_exp"],
	embedding?:PartialObjects["vector_comparison_exp"],
	metadata?:PartialObjects["jsonb_comparison_exp"],
	name?:PartialObjects["String_comparison_exp"],
	parent?:PartialObjects["String_comparison_exp"],
	parent_tree?:PartialObjects["String_comparison_exp"]
},
	/** unique or primary key constraints on table "event_types" */
["event_types_constraint"]:event_types_constraint,
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
["event_types_delete_at_path_input"]: {
	metadata?:string[]
},
	/** delete the array element with specified index (negative integers count from the
end). throws an error if top level container is not an array */
["event_types_delete_elem_input"]: {
	metadata?:number
},
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
["event_types_delete_key_input"]: {
	metadata?:string
},
	/** input type for inserting data into table "event_types" */
["event_types_insert_input"]: {
	children?:PartialObjects["event_types_arr_rel_insert_input"],
	embedding?:PartialObjects["vector"],
	metadata?:PartialObjects["jsonb"],
	name?:string,
	parent?:string
},
	/** aggregate max on columns */
["event_types_max_fields"]: {
		__typename?: "event_types_max_fields";
			name?:string,
			parent?:string,
			/** A computed field, executes function "get_event_type_path" */
	parent_tree?:string
	},
	/** order by max() on columns of table "event_types" */
["event_types_max_order_by"]: {
	name?:PartialObjects["order_by"],
	parent?:PartialObjects["order_by"]
},
	/** aggregate min on columns */
["event_types_min_fields"]: {
		__typename?: "event_types_min_fields";
			name?:string,
			parent?:string,
			/** A computed field, executes function "get_event_type_path" */
	parent_tree?:string
	},
	/** order by min() on columns of table "event_types" */
["event_types_min_order_by"]: {
	name?:PartialObjects["order_by"],
	parent?:PartialObjects["order_by"]
},
	/** response of any mutation on the table "event_types" */
["event_types_mutation_response"]: {
		__typename?: "event_types_mutation_response";
			/** number of rows affected by the mutation */
	affected_rows?:number,
			/** data from the rows affected by the mutation */
	returning?:PartialObjects["event_types"][]
	},
	/** input type for inserting object relation for remote table "event_types" */
["event_types_obj_rel_insert_input"]: {
	data:PartialObjects["event_types_insert_input"],
	/** upsert condition */
	on_conflict?:PartialObjects["event_types_on_conflict"]
},
	/** on_conflict condition type for table "event_types" */
["event_types_on_conflict"]: {
	constraint:PartialObjects["event_types_constraint"],
	update_columns:PartialObjects["event_types_update_column"][],
	where?:PartialObjects["event_types_bool_exp"]
},
	/** Ordering options when selecting data from "event_types". */
["event_types_order_by"]: {
	children_aggregate?:PartialObjects["event_types_aggregate_order_by"],
	embedding?:PartialObjects["order_by"],
	metadata?:PartialObjects["order_by"],
	name?:PartialObjects["order_by"],
	parent?:PartialObjects["order_by"],
	parent_tree?:PartialObjects["order_by"]
},
	/** primary key columns input for table: event_types */
["event_types_pk_columns_input"]: {
	name:string
},
	/** prepend existing jsonb value of filtered columns with new jsonb value */
["event_types_prepend_input"]: {
	metadata?:PartialObjects["jsonb"]
},
	/** select columns of table "event_types" */
["event_types_select_column"]:event_types_select_column,
	/** input type for updating data in table "event_types" */
["event_types_set_input"]: {
	embedding?:PartialObjects["vector"],
	metadata?:PartialObjects["jsonb"],
	name?:string,
	parent?:string
},
	/** Streaming cursor of the table "event_types" */
["event_types_stream_cursor_input"]: {
	/** Stream column input with initial value */
	initial_value:PartialObjects["event_types_stream_cursor_value_input"],
	/** cursor ordering */
	ordering?:PartialObjects["cursor_ordering"]
},
	/** Initial value of the column from where the streaming should start */
["event_types_stream_cursor_value_input"]: {
	embedding?:PartialObjects["vector"],
	metadata?:PartialObjects["jsonb"],
	name?:string,
	parent?:string
},
	/** update columns of table "event_types" */
["event_types_update_column"]:event_types_update_column,
	["event_types_updates"]: {
	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:PartialObjects["event_types_append_input"],
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:PartialObjects["event_types_delete_at_path_input"],
	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:PartialObjects["event_types_delete_elem_input"],
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:PartialObjects["event_types_delete_key_input"],
	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:PartialObjects["event_types_prepend_input"],
	/** sets the columns of the filtered rows to the given values */
	_set?:PartialObjects["event_types_set_input"],
	/** filter the rows which have to be updated */
	where:PartialObjects["event_types_bool_exp"]
},
	/** columns and relationships of "events" */
["events"]: {
		__typename?: "events";
			/** A computed field, executes function "event_associations" */
	associations?:PartialObjects["associations"][],
			/** An array relationship */
	children?:PartialObjects["events"][],
			/** An aggregate relationship */
	children_aggregate?:PartialObjects["events_aggregate"],
			/** A computed field, executes function "event_duration" */
	computed_cost_time?:number,
			/** cents */
	cost_money?:number,
			/** seconds */
	cost_time?:number,
			end_time?:PartialObjects["timestamp"],
			/** An array relationship */
	event_tags?:PartialObjects["event_tag"][],
			/** An aggregate relationship */
	event_tags_aggregate?:PartialObjects["event_tag_aggregate"],
			event_type?:string,
			/** An object relationship */
	event_type_object?:PartialObjects["event_types"],
			goal_id?:number,
			id?:number,
			/** An object relationship */
	interaction?:PartialObjects["interactions"],
			interaction_id?:number,
			logs?:PartialObjects["jsonb"],
			metadata?:PartialObjects["jsonb"],
			/** An object relationship */
	parent?:PartialObjects["events"],
			parent_id?:number,
			start_time?:PartialObjects["timestamp"],
			status?:string,
			/** An object relationship */
	user?:PartialObjects["users"],
			user_id?:number
	},
	/** aggregated selection of "events" */
["events_aggregate"]: {
		__typename?: "events_aggregate";
			aggregate?:PartialObjects["events_aggregate_fields"],
			nodes?:PartialObjects["events"][]
	},
	["events_aggregate_bool_exp"]: {
	count?:PartialObjects["events_aggregate_bool_exp_count"]
},
	["events_aggregate_bool_exp_count"]: {
	arguments?:PartialObjects["events_select_column"][],
	distinct?:boolean,
	filter?:PartialObjects["events_bool_exp"],
	predicate:PartialObjects["Int_comparison_exp"]
},
	/** aggregate fields of "events" */
["events_aggregate_fields"]: {
		__typename?: "events_aggregate_fields";
			avg?:PartialObjects["events_avg_fields"],
			count?:number,
			max?:PartialObjects["events_max_fields"],
			min?:PartialObjects["events_min_fields"],
			stddev?:PartialObjects["events_stddev_fields"],
			stddev_pop?:PartialObjects["events_stddev_pop_fields"],
			stddev_samp?:PartialObjects["events_stddev_samp_fields"],
			sum?:PartialObjects["events_sum_fields"],
			var_pop?:PartialObjects["events_var_pop_fields"],
			var_samp?:PartialObjects["events_var_samp_fields"],
			variance?:PartialObjects["events_variance_fields"]
	},
	/** order by aggregate values of table "events" */
["events_aggregate_order_by"]: {
	avg?:PartialObjects["events_avg_order_by"],
	count?:PartialObjects["order_by"],
	max?:PartialObjects["events_max_order_by"],
	min?:PartialObjects["events_min_order_by"],
	stddev?:PartialObjects["events_stddev_order_by"],
	stddev_pop?:PartialObjects["events_stddev_pop_order_by"],
	stddev_samp?:PartialObjects["events_stddev_samp_order_by"],
	sum?:PartialObjects["events_sum_order_by"],
	var_pop?:PartialObjects["events_var_pop_order_by"],
	var_samp?:PartialObjects["events_var_samp_order_by"],
	variance?:PartialObjects["events_variance_order_by"]
},
	/** append existing jsonb value of filtered columns with new jsonb value */
["events_append_input"]: {
	logs?:PartialObjects["jsonb"],
	metadata?:PartialObjects["jsonb"]
},
	/** input type for inserting array relation for remote table "events" */
["events_arr_rel_insert_input"]: {
	data:PartialObjects["events_insert_input"][],
	/** upsert condition */
	on_conflict?:PartialObjects["events_on_conflict"]
},
	/** aggregate avg on columns */
["events_avg_fields"]: {
		__typename?: "events_avg_fields";
			/** A computed field, executes function "event_duration" */
	computed_cost_time?:number,
			/** cents */
	cost_money?:number,
			/** seconds */
	cost_time?:number,
			goal_id?:number,
			id?:number,
			interaction_id?:number,
			parent_id?:number,
			user_id?:number
	},
	/** order by avg() on columns of table "events" */
["events_avg_order_by"]: {
	/** cents */
	cost_money?:PartialObjects["order_by"],
	/** seconds */
	cost_time?:PartialObjects["order_by"],
	goal_id?:PartialObjects["order_by"],
	id?:PartialObjects["order_by"],
	interaction_id?:PartialObjects["order_by"],
	parent_id?:PartialObjects["order_by"],
	user_id?:PartialObjects["order_by"]
},
	/** Boolean expression to filter rows from the table "events". All fields are combined with a logical 'AND'. */
["events_bool_exp"]: {
	_and?:PartialObjects["events_bool_exp"][],
	_not?:PartialObjects["events_bool_exp"],
	_or?:PartialObjects["events_bool_exp"][],
	associations?:PartialObjects["associations_bool_exp"],
	children?:PartialObjects["events_bool_exp"],
	children_aggregate?:PartialObjects["events_aggregate_bool_exp"],
	computed_cost_time?:PartialObjects["Int_comparison_exp"],
	cost_money?:PartialObjects["Int_comparison_exp"],
	cost_time?:PartialObjects["Int_comparison_exp"],
	end_time?:PartialObjects["timestamp_comparison_exp"],
	event_tags?:PartialObjects["event_tag_bool_exp"],
	event_tags_aggregate?:PartialObjects["event_tag_aggregate_bool_exp"],
	event_type?:PartialObjects["String_comparison_exp"],
	event_type_object?:PartialObjects["event_types_bool_exp"],
	goal_id?:PartialObjects["Int_comparison_exp"],
	id?:PartialObjects["Int_comparison_exp"],
	interaction?:PartialObjects["interactions_bool_exp"],
	interaction_id?:PartialObjects["Int_comparison_exp"],
	logs?:PartialObjects["jsonb_comparison_exp"],
	metadata?:PartialObjects["jsonb_comparison_exp"],
	parent?:PartialObjects["events_bool_exp"],
	parent_id?:PartialObjects["Int_comparison_exp"],
	start_time?:PartialObjects["timestamp_comparison_exp"],
	status?:PartialObjects["String_comparison_exp"],
	user?:PartialObjects["users_bool_exp"],
	user_id?:PartialObjects["Int_comparison_exp"]
},
	/** unique or primary key constraints on table "events" */
["events_constraint"]:events_constraint,
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
["events_delete_at_path_input"]: {
	logs?:string[],
	metadata?:string[]
},
	/** delete the array element with specified index (negative integers count from the
end). throws an error if top level container is not an array */
["events_delete_elem_input"]: {
	logs?:number,
	metadata?:number
},
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
["events_delete_key_input"]: {
	logs?:string,
	metadata?:string
},
	/** input type for incrementing numeric columns in table "events" */
["events_inc_input"]: {
	/** cents */
	cost_money?:number,
	/** seconds */
	cost_time?:number,
	goal_id?:number,
	id?:number,
	interaction_id?:number,
	parent_id?:number,
	user_id?:number
},
	/** input type for inserting data into table "events" */
["events_insert_input"]: {
	children?:PartialObjects["events_arr_rel_insert_input"],
	/** cents */
	cost_money?:number,
	/** seconds */
	cost_time?:number,
	end_time?:PartialObjects["timestamp"],
	event_tags?:PartialObjects["event_tag_arr_rel_insert_input"],
	event_type?:string,
	event_type_object?:PartialObjects["event_types_obj_rel_insert_input"],
	goal_id?:number,
	id?:number,
	interaction?:PartialObjects["interactions_obj_rel_insert_input"],
	interaction_id?:number,
	logs?:PartialObjects["jsonb"],
	metadata?:PartialObjects["jsonb"],
	parent?:PartialObjects["events_obj_rel_insert_input"],
	parent_id?:number,
	start_time?:PartialObjects["timestamp"],
	status?:string,
	user?:PartialObjects["users_obj_rel_insert_input"],
	user_id?:number
},
	/** aggregate max on columns */
["events_max_fields"]: {
		__typename?: "events_max_fields";
			/** A computed field, executes function "event_duration" */
	computed_cost_time?:number,
			/** cents */
	cost_money?:number,
			/** seconds */
	cost_time?:number,
			end_time?:PartialObjects["timestamp"],
			event_type?:string,
			goal_id?:number,
			id?:number,
			interaction_id?:number,
			parent_id?:number,
			start_time?:PartialObjects["timestamp"],
			status?:string,
			user_id?:number
	},
	/** order by max() on columns of table "events" */
["events_max_order_by"]: {
	/** cents */
	cost_money?:PartialObjects["order_by"],
	/** seconds */
	cost_time?:PartialObjects["order_by"],
	end_time?:PartialObjects["order_by"],
	event_type?:PartialObjects["order_by"],
	goal_id?:PartialObjects["order_by"],
	id?:PartialObjects["order_by"],
	interaction_id?:PartialObjects["order_by"],
	parent_id?:PartialObjects["order_by"],
	start_time?:PartialObjects["order_by"],
	status?:PartialObjects["order_by"],
	user_id?:PartialObjects["order_by"]
},
	/** aggregate min on columns */
["events_min_fields"]: {
		__typename?: "events_min_fields";
			/** A computed field, executes function "event_duration" */
	computed_cost_time?:number,
			/** cents */
	cost_money?:number,
			/** seconds */
	cost_time?:number,
			end_time?:PartialObjects["timestamp"],
			event_type?:string,
			goal_id?:number,
			id?:number,
			interaction_id?:number,
			parent_id?:number,
			start_time?:PartialObjects["timestamp"],
			status?:string,
			user_id?:number
	},
	/** order by min() on columns of table "events" */
["events_min_order_by"]: {
	/** cents */
	cost_money?:PartialObjects["order_by"],
	/** seconds */
	cost_time?:PartialObjects["order_by"],
	end_time?:PartialObjects["order_by"],
	event_type?:PartialObjects["order_by"],
	goal_id?:PartialObjects["order_by"],
	id?:PartialObjects["order_by"],
	interaction_id?:PartialObjects["order_by"],
	parent_id?:PartialObjects["order_by"],
	start_time?:PartialObjects["order_by"],
	status?:PartialObjects["order_by"],
	user_id?:PartialObjects["order_by"]
},
	/** response of any mutation on the table "events" */
["events_mutation_response"]: {
		__typename?: "events_mutation_response";
			/** number of rows affected by the mutation */
	affected_rows?:number,
			/** data from the rows affected by the mutation */
	returning?:PartialObjects["events"][]
	},
	/** input type for inserting object relation for remote table "events" */
["events_obj_rel_insert_input"]: {
	data:PartialObjects["events_insert_input"],
	/** upsert condition */
	on_conflict?:PartialObjects["events_on_conflict"]
},
	/** on_conflict condition type for table "events" */
["events_on_conflict"]: {
	constraint:PartialObjects["events_constraint"],
	update_columns:PartialObjects["events_update_column"][],
	where?:PartialObjects["events_bool_exp"]
},
	/** Ordering options when selecting data from "events". */
["events_order_by"]: {
	associations_aggregate?:PartialObjects["associations_aggregate_order_by"],
	children_aggregate?:PartialObjects["events_aggregate_order_by"],
	computed_cost_time?:PartialObjects["order_by"],
	cost_money?:PartialObjects["order_by"],
	cost_time?:PartialObjects["order_by"],
	end_time?:PartialObjects["order_by"],
	event_tags_aggregate?:PartialObjects["event_tag_aggregate_order_by"],
	event_type?:PartialObjects["order_by"],
	event_type_object?:PartialObjects["event_types_order_by"],
	goal_id?:PartialObjects["order_by"],
	id?:PartialObjects["order_by"],
	interaction?:PartialObjects["interactions_order_by"],
	interaction_id?:PartialObjects["order_by"],
	logs?:PartialObjects["order_by"],
	metadata?:PartialObjects["order_by"],
	parent?:PartialObjects["events_order_by"],
	parent_id?:PartialObjects["order_by"],
	start_time?:PartialObjects["order_by"],
	status?:PartialObjects["order_by"],
	user?:PartialObjects["users_order_by"],
	user_id?:PartialObjects["order_by"]
},
	/** primary key columns input for table: events */
["events_pk_columns_input"]: {
	id:number
},
	/** prepend existing jsonb value of filtered columns with new jsonb value */
["events_prepend_input"]: {
	logs?:PartialObjects["jsonb"],
	metadata?:PartialObjects["jsonb"]
},
	/** select columns of table "events" */
["events_select_column"]:events_select_column,
	/** input type for updating data in table "events" */
["events_set_input"]: {
	/** cents */
	cost_money?:number,
	/** seconds */
	cost_time?:number,
	end_time?:PartialObjects["timestamp"],
	event_type?:string,
	goal_id?:number,
	id?:number,
	interaction_id?:number,
	logs?:PartialObjects["jsonb"],
	metadata?:PartialObjects["jsonb"],
	parent_id?:number,
	start_time?:PartialObjects["timestamp"],
	status?:string,
	user_id?:number
},
	/** aggregate stddev on columns */
["events_stddev_fields"]: {
		__typename?: "events_stddev_fields";
			/** A computed field, executes function "event_duration" */
	computed_cost_time?:number,
			/** cents */
	cost_money?:number,
			/** seconds */
	cost_time?:number,
			goal_id?:number,
			id?:number,
			interaction_id?:number,
			parent_id?:number,
			user_id?:number
	},
	/** order by stddev() on columns of table "events" */
["events_stddev_order_by"]: {
	/** cents */
	cost_money?:PartialObjects["order_by"],
	/** seconds */
	cost_time?:PartialObjects["order_by"],
	goal_id?:PartialObjects["order_by"],
	id?:PartialObjects["order_by"],
	interaction_id?:PartialObjects["order_by"],
	parent_id?:PartialObjects["order_by"],
	user_id?:PartialObjects["order_by"]
},
	/** aggregate stddev_pop on columns */
["events_stddev_pop_fields"]: {
		__typename?: "events_stddev_pop_fields";
			/** A computed field, executes function "event_duration" */
	computed_cost_time?:number,
			/** cents */
	cost_money?:number,
			/** seconds */
	cost_time?:number,
			goal_id?:number,
			id?:number,
			interaction_id?:number,
			parent_id?:number,
			user_id?:number
	},
	/** order by stddev_pop() on columns of table "events" */
["events_stddev_pop_order_by"]: {
	/** cents */
	cost_money?:PartialObjects["order_by"],
	/** seconds */
	cost_time?:PartialObjects["order_by"],
	goal_id?:PartialObjects["order_by"],
	id?:PartialObjects["order_by"],
	interaction_id?:PartialObjects["order_by"],
	parent_id?:PartialObjects["order_by"],
	user_id?:PartialObjects["order_by"]
},
	/** aggregate stddev_samp on columns */
["events_stddev_samp_fields"]: {
		__typename?: "events_stddev_samp_fields";
			/** A computed field, executes function "event_duration" */
	computed_cost_time?:number,
			/** cents */
	cost_money?:number,
			/** seconds */
	cost_time?:number,
			goal_id?:number,
			id?:number,
			interaction_id?:number,
			parent_id?:number,
			user_id?:number
	},
	/** order by stddev_samp() on columns of table "events" */
["events_stddev_samp_order_by"]: {
	/** cents */
	cost_money?:PartialObjects["order_by"],
	/** seconds */
	cost_time?:PartialObjects["order_by"],
	goal_id?:PartialObjects["order_by"],
	id?:PartialObjects["order_by"],
	interaction_id?:PartialObjects["order_by"],
	parent_id?:PartialObjects["order_by"],
	user_id?:PartialObjects["order_by"]
},
	/** Streaming cursor of the table "events" */
["events_stream_cursor_input"]: {
	/** Stream column input with initial value */
	initial_value:PartialObjects["events_stream_cursor_value_input"],
	/** cursor ordering */
	ordering?:PartialObjects["cursor_ordering"]
},
	/** Initial value of the column from where the streaming should start */
["events_stream_cursor_value_input"]: {
	/** cents */
	cost_money?:number,
	/** seconds */
	cost_time?:number,
	end_time?:PartialObjects["timestamp"],
	event_type?:string,
	goal_id?:number,
	id?:number,
	interaction_id?:number,
	logs?:PartialObjects["jsonb"],
	metadata?:PartialObjects["jsonb"],
	parent_id?:number,
	start_time?:PartialObjects["timestamp"],
	status?:string,
	user_id?:number
},
	/** aggregate sum on columns */
["events_sum_fields"]: {
		__typename?: "events_sum_fields";
			/** A computed field, executes function "event_duration" */
	computed_cost_time?:number,
			/** cents */
	cost_money?:number,
			/** seconds */
	cost_time?:number,
			goal_id?:number,
			id?:number,
			interaction_id?:number,
			parent_id?:number,
			user_id?:number
	},
	/** order by sum() on columns of table "events" */
["events_sum_order_by"]: {
	/** cents */
	cost_money?:PartialObjects["order_by"],
	/** seconds */
	cost_time?:PartialObjects["order_by"],
	goal_id?:PartialObjects["order_by"],
	id?:PartialObjects["order_by"],
	interaction_id?:PartialObjects["order_by"],
	parent_id?:PartialObjects["order_by"],
	user_id?:PartialObjects["order_by"]
},
	/** update columns of table "events" */
["events_update_column"]:events_update_column,
	["events_updates"]: {
	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:PartialObjects["events_append_input"],
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:PartialObjects["events_delete_at_path_input"],
	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:PartialObjects["events_delete_elem_input"],
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:PartialObjects["events_delete_key_input"],
	/** increments the numeric columns with given value of the filtered values */
	_inc?:PartialObjects["events_inc_input"],
	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:PartialObjects["events_prepend_input"],
	/** sets the columns of the filtered rows to the given values */
	_set?:PartialObjects["events_set_input"],
	/** filter the rows which have to be updated */
	where:PartialObjects["events_bool_exp"]
},
	/** aggregate var_pop on columns */
["events_var_pop_fields"]: {
		__typename?: "events_var_pop_fields";
			/** A computed field, executes function "event_duration" */
	computed_cost_time?:number,
			/** cents */
	cost_money?:number,
			/** seconds */
	cost_time?:number,
			goal_id?:number,
			id?:number,
			interaction_id?:number,
			parent_id?:number,
			user_id?:number
	},
	/** order by var_pop() on columns of table "events" */
["events_var_pop_order_by"]: {
	/** cents */
	cost_money?:PartialObjects["order_by"],
	/** seconds */
	cost_time?:PartialObjects["order_by"],
	goal_id?:PartialObjects["order_by"],
	id?:PartialObjects["order_by"],
	interaction_id?:PartialObjects["order_by"],
	parent_id?:PartialObjects["order_by"],
	user_id?:PartialObjects["order_by"]
},
	/** aggregate var_samp on columns */
["events_var_samp_fields"]: {
		__typename?: "events_var_samp_fields";
			/** A computed field, executes function "event_duration" */
	computed_cost_time?:number,
			/** cents */
	cost_money?:number,
			/** seconds */
	cost_time?:number,
			goal_id?:number,
			id?:number,
			interaction_id?:number,
			parent_id?:number,
			user_id?:number
	},
	/** order by var_samp() on columns of table "events" */
["events_var_samp_order_by"]: {
	/** cents */
	cost_money?:PartialObjects["order_by"],
	/** seconds */
	cost_time?:PartialObjects["order_by"],
	goal_id?:PartialObjects["order_by"],
	id?:PartialObjects["order_by"],
	interaction_id?:PartialObjects["order_by"],
	parent_id?:PartialObjects["order_by"],
	user_id?:PartialObjects["order_by"]
},
	/** aggregate variance on columns */
["events_variance_fields"]: {
		__typename?: "events_variance_fields";
			/** A computed field, executes function "event_duration" */
	computed_cost_time?:number,
			/** cents */
	cost_money?:number,
			/** seconds */
	cost_time?:number,
			goal_id?:number,
			id?:number,
			interaction_id?:number,
			parent_id?:number,
			user_id?:number
	},
	/** order by variance() on columns of table "events" */
["events_variance_order_by"]: {
	/** cents */
	cost_money?:PartialObjects["order_by"],
	/** seconds */
	cost_time?:PartialObjects["order_by"],
	goal_id?:PartialObjects["order_by"],
	id?:PartialObjects["order_by"],
	interaction_id?:PartialObjects["order_by"],
	parent_id?:PartialObjects["order_by"],
	user_id?:PartialObjects["order_by"]
},
	["fetch_associations_args"]: {
	from_row_id?:number,
	from_row_type?:string
},
	["float8"]:any,
	/** Boolean expression to compare columns of type "float8". All fields are combined with logical 'AND'. */
["float8_comparison_exp"]: {
	_eq?:PartialObjects["float8"],
	_gt?:PartialObjects["float8"],
	_gte?:PartialObjects["float8"],
	_in?:PartialObjects["float8"][],
	_is_null?:boolean,
	_lt?:PartialObjects["float8"],
	_lte?:PartialObjects["float8"],
	_neq?:PartialObjects["float8"],
	_nin?:PartialObjects["float8"][]
},
	["geography"]:any,
	["geography_cast_exp"]: {
	geometry?:PartialObjects["geometry_comparison_exp"]
},
	/** Boolean expression to compare columns of type "geography". All fields are combined with logical 'AND'. */
["geography_comparison_exp"]: {
	_cast?:PartialObjects["geography_cast_exp"],
	_eq?:PartialObjects["geography"],
	_gt?:PartialObjects["geography"],
	_gte?:PartialObjects["geography"],
	_in?:PartialObjects["geography"][],
	_is_null?:boolean,
	_lt?:PartialObjects["geography"],
	_lte?:PartialObjects["geography"],
	_neq?:PartialObjects["geography"],
	_nin?:PartialObjects["geography"][],
	/** is the column within a given distance from the given geography value */
	_st_d_within?:PartialObjects["st_d_within_geography_input"],
	/** does the column spatially intersect the given geography value */
	_st_intersects?:PartialObjects["geography"]
},
	["geometry"]:any,
	["geometry_cast_exp"]: {
	geography?:PartialObjects["geography_comparison_exp"]
},
	/** Boolean expression to compare columns of type "geometry". All fields are combined with logical 'AND'. */
["geometry_comparison_exp"]: {
	_cast?:PartialObjects["geometry_cast_exp"],
	_eq?:PartialObjects["geometry"],
	_gt?:PartialObjects["geometry"],
	_gte?:PartialObjects["geometry"],
	_in?:PartialObjects["geometry"][],
	_is_null?:boolean,
	_lt?:PartialObjects["geometry"],
	_lte?:PartialObjects["geometry"],
	_neq?:PartialObjects["geometry"],
	_nin?:PartialObjects["geometry"][],
	/** is the column within a given 3D distance from the given geometry value */
	_st_3d_d_within?:PartialObjects["st_d_within_input"],
	/** does the column spatially intersect the given geometry value in 3D */
	_st_3d_intersects?:PartialObjects["geometry"],
	/** does the column contain the given geometry value */
	_st_contains?:PartialObjects["geometry"],
	/** does the column cross the given geometry value */
	_st_crosses?:PartialObjects["geometry"],
	/** is the column within a given distance from the given geometry value */
	_st_d_within?:PartialObjects["st_d_within_input"],
	/** is the column equal to given geometry value (directionality is ignored) */
	_st_equals?:PartialObjects["geometry"],
	/** does the column spatially intersect the given geometry value */
	_st_intersects?:PartialObjects["geometry"],
	/** does the column 'spatially overlap' (intersect but not completely contain) the given geometry value */
	_st_overlaps?:PartialObjects["geometry"],
	/** does the column have atleast one point in common with the given geometry value */
	_st_touches?:PartialObjects["geometry"],
	/** is the column contained in the given geometry value */
	_st_within?:PartialObjects["geometry"]
},
	/** columns and relationships of "goals" */
["goals"]: {
		__typename?: "goals";
			created?:PartialObjects["timestamptz"],
			frequency?:PartialObjects["jsonb"],
			id?:number,
			name?:string,
			nl_description?:string,
			status?:string,
			/** An object relationship */
	todo?:PartialObjects["todos"],
			/** An object relationship */
	user?:PartialObjects["users"],
			user_id?:number
	},
	/** aggregated selection of "goals" */
["goals_aggregate"]: {
		__typename?: "goals_aggregate";
			aggregate?:PartialObjects["goals_aggregate_fields"],
			nodes?:PartialObjects["goals"][]
	},
	/** aggregate fields of "goals" */
["goals_aggregate_fields"]: {
		__typename?: "goals_aggregate_fields";
			avg?:PartialObjects["goals_avg_fields"],
			count?:number,
			max?:PartialObjects["goals_max_fields"],
			min?:PartialObjects["goals_min_fields"],
			stddev?:PartialObjects["goals_stddev_fields"],
			stddev_pop?:PartialObjects["goals_stddev_pop_fields"],
			stddev_samp?:PartialObjects["goals_stddev_samp_fields"],
			sum?:PartialObjects["goals_sum_fields"],
			var_pop?:PartialObjects["goals_var_pop_fields"],
			var_samp?:PartialObjects["goals_var_samp_fields"],
			variance?:PartialObjects["goals_variance_fields"]
	},
	/** append existing jsonb value of filtered columns with new jsonb value */
["goals_append_input"]: {
	frequency?:PartialObjects["jsonb"]
},
	/** aggregate avg on columns */
["goals_avg_fields"]: {
		__typename?: "goals_avg_fields";
			id?:number,
			user_id?:number
	},
	/** Boolean expression to filter rows from the table "goals". All fields are combined with a logical 'AND'. */
["goals_bool_exp"]: {
	_and?:PartialObjects["goals_bool_exp"][],
	_not?:PartialObjects["goals_bool_exp"],
	_or?:PartialObjects["goals_bool_exp"][],
	created?:PartialObjects["timestamptz_comparison_exp"],
	frequency?:PartialObjects["jsonb_comparison_exp"],
	id?:PartialObjects["Int_comparison_exp"],
	name?:PartialObjects["String_comparison_exp"],
	nl_description?:PartialObjects["String_comparison_exp"],
	status?:PartialObjects["String_comparison_exp"],
	todo?:PartialObjects["todos_bool_exp"],
	user?:PartialObjects["users_bool_exp"],
	user_id?:PartialObjects["Int_comparison_exp"]
},
	/** unique or primary key constraints on table "goals" */
["goals_constraint"]:goals_constraint,
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
["goals_delete_at_path_input"]: {
	frequency?:string[]
},
	/** delete the array element with specified index (negative integers count from the
end). throws an error if top level container is not an array */
["goals_delete_elem_input"]: {
	frequency?:number
},
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
["goals_delete_key_input"]: {
	frequency?:string
},
	/** input type for incrementing numeric columns in table "goals" */
["goals_inc_input"]: {
	id?:number,
	user_id?:number
},
	/** input type for inserting data into table "goals" */
["goals_insert_input"]: {
	created?:PartialObjects["timestamptz"],
	frequency?:PartialObjects["jsonb"],
	id?:number,
	name?:string,
	nl_description?:string,
	status?:string,
	todo?:PartialObjects["todos_obj_rel_insert_input"],
	user?:PartialObjects["users_obj_rel_insert_input"],
	user_id?:number
},
	/** aggregate max on columns */
["goals_max_fields"]: {
		__typename?: "goals_max_fields";
			created?:PartialObjects["timestamptz"],
			id?:number,
			name?:string,
			nl_description?:string,
			status?:string,
			user_id?:number
	},
	/** aggregate min on columns */
["goals_min_fields"]: {
		__typename?: "goals_min_fields";
			created?:PartialObjects["timestamptz"],
			id?:number,
			name?:string,
			nl_description?:string,
			status?:string,
			user_id?:number
	},
	/** response of any mutation on the table "goals" */
["goals_mutation_response"]: {
		__typename?: "goals_mutation_response";
			/** number of rows affected by the mutation */
	affected_rows?:number,
			/** data from the rows affected by the mutation */
	returning?:PartialObjects["goals"][]
	},
	/** input type for inserting object relation for remote table "goals" */
["goals_obj_rel_insert_input"]: {
	data:PartialObjects["goals_insert_input"],
	/** upsert condition */
	on_conflict?:PartialObjects["goals_on_conflict"]
},
	/** on_conflict condition type for table "goals" */
["goals_on_conflict"]: {
	constraint:PartialObjects["goals_constraint"],
	update_columns:PartialObjects["goals_update_column"][],
	where?:PartialObjects["goals_bool_exp"]
},
	/** Ordering options when selecting data from "goals". */
["goals_order_by"]: {
	created?:PartialObjects["order_by"],
	frequency?:PartialObjects["order_by"],
	id?:PartialObjects["order_by"],
	name?:PartialObjects["order_by"],
	nl_description?:PartialObjects["order_by"],
	status?:PartialObjects["order_by"],
	todo?:PartialObjects["todos_order_by"],
	user?:PartialObjects["users_order_by"],
	user_id?:PartialObjects["order_by"]
},
	/** primary key columns input for table: goals */
["goals_pk_columns_input"]: {
	id:number
},
	/** prepend existing jsonb value of filtered columns with new jsonb value */
["goals_prepend_input"]: {
	frequency?:PartialObjects["jsonb"]
},
	/** select columns of table "goals" */
["goals_select_column"]:goals_select_column,
	/** input type for updating data in table "goals" */
["goals_set_input"]: {
	created?:PartialObjects["timestamptz"],
	frequency?:PartialObjects["jsonb"],
	id?:number,
	name?:string,
	nl_description?:string,
	status?:string,
	user_id?:number
},
	/** aggregate stddev on columns */
["goals_stddev_fields"]: {
		__typename?: "goals_stddev_fields";
			id?:number,
			user_id?:number
	},
	/** aggregate stddev_pop on columns */
["goals_stddev_pop_fields"]: {
		__typename?: "goals_stddev_pop_fields";
			id?:number,
			user_id?:number
	},
	/** aggregate stddev_samp on columns */
["goals_stddev_samp_fields"]: {
		__typename?: "goals_stddev_samp_fields";
			id?:number,
			user_id?:number
	},
	/** Streaming cursor of the table "goals" */
["goals_stream_cursor_input"]: {
	/** Stream column input with initial value */
	initial_value:PartialObjects["goals_stream_cursor_value_input"],
	/** cursor ordering */
	ordering?:PartialObjects["cursor_ordering"]
},
	/** Initial value of the column from where the streaming should start */
["goals_stream_cursor_value_input"]: {
	created?:PartialObjects["timestamptz"],
	frequency?:PartialObjects["jsonb"],
	id?:number,
	name?:string,
	nl_description?:string,
	status?:string,
	user_id?:number
},
	/** aggregate sum on columns */
["goals_sum_fields"]: {
		__typename?: "goals_sum_fields";
			id?:number,
			user_id?:number
	},
	/** update columns of table "goals" */
["goals_update_column"]:goals_update_column,
	["goals_updates"]: {
	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:PartialObjects["goals_append_input"],
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:PartialObjects["goals_delete_at_path_input"],
	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:PartialObjects["goals_delete_elem_input"],
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:PartialObjects["goals_delete_key_input"],
	/** increments the numeric columns with given value of the filtered values */
	_inc?:PartialObjects["goals_inc_input"],
	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:PartialObjects["goals_prepend_input"],
	/** sets the columns of the filtered rows to the given values */
	_set?:PartialObjects["goals_set_input"],
	/** filter the rows which have to be updated */
	where:PartialObjects["goals_bool_exp"]
},
	/** aggregate var_pop on columns */
["goals_var_pop_fields"]: {
		__typename?: "goals_var_pop_fields";
			id?:number,
			user_id?:number
	},
	/** aggregate var_samp on columns */
["goals_var_samp_fields"]: {
		__typename?: "goals_var_samp_fields";
			id?:number,
			user_id?:number
	},
	/** aggregate variance on columns */
["goals_variance_fields"]: {
		__typename?: "goals_variance_fields";
			id?:number,
			user_id?:number
	},
	/** Boolean expression to compare columns of type "Int". All fields are combined with logical 'AND'. */
["Int_comparison_exp"]: {
	_eq?:number,
	_gt?:number,
	_gte?:number,
	_in?:number[],
	_is_null?:boolean,
	_lt?:number,
	_lte?:number,
	_neq?:number,
	_nin?:number[]
},
	/** columns and relationships of "interactions" */
["interactions"]: {
		__typename?: "interactions";
			content?:string,
			content_type?:string,
			debug?:PartialObjects["jsonb"],
			embedding?:PartialObjects["vector"],
			/** An array relationship */
	events?:PartialObjects["events"][],
			/** An aggregate relationship */
	events_aggregate?:PartialObjects["events_aggregate"],
			id?:number,
			match_score?:PartialObjects["float8"],
			timestamp?:PartialObjects["timestamptz"],
			user_id?:number
	},
	/** aggregated selection of "interactions" */
["interactions_aggregate"]: {
		__typename?: "interactions_aggregate";
			aggregate?:PartialObjects["interactions_aggregate_fields"],
			nodes?:PartialObjects["interactions"][]
	},
	/** aggregate fields of "interactions" */
["interactions_aggregate_fields"]: {
		__typename?: "interactions_aggregate_fields";
			avg?:PartialObjects["interactions_avg_fields"],
			count?:number,
			max?:PartialObjects["interactions_max_fields"],
			min?:PartialObjects["interactions_min_fields"],
			stddev?:PartialObjects["interactions_stddev_fields"],
			stddev_pop?:PartialObjects["interactions_stddev_pop_fields"],
			stddev_samp?:PartialObjects["interactions_stddev_samp_fields"],
			sum?:PartialObjects["interactions_sum_fields"],
			var_pop?:PartialObjects["interactions_var_pop_fields"],
			var_samp?:PartialObjects["interactions_var_samp_fields"],
			variance?:PartialObjects["interactions_variance_fields"]
	},
	/** append existing jsonb value of filtered columns with new jsonb value */
["interactions_append_input"]: {
	debug?:PartialObjects["jsonb"]
},
	/** aggregate avg on columns */
["interactions_avg_fields"]: {
		__typename?: "interactions_avg_fields";
			id?:number,
			match_score?:number,
			user_id?:number
	},
	/** Boolean expression to filter rows from the table "interactions". All fields are combined with a logical 'AND'. */
["interactions_bool_exp"]: {
	_and?:PartialObjects["interactions_bool_exp"][],
	_not?:PartialObjects["interactions_bool_exp"],
	_or?:PartialObjects["interactions_bool_exp"][],
	content?:PartialObjects["String_comparison_exp"],
	content_type?:PartialObjects["String_comparison_exp"],
	debug?:PartialObjects["jsonb_comparison_exp"],
	embedding?:PartialObjects["vector_comparison_exp"],
	events?:PartialObjects["events_bool_exp"],
	events_aggregate?:PartialObjects["events_aggregate_bool_exp"],
	id?:PartialObjects["Int_comparison_exp"],
	match_score?:PartialObjects["float8_comparison_exp"],
	timestamp?:PartialObjects["timestamptz_comparison_exp"],
	user_id?:PartialObjects["Int_comparison_exp"]
},
	/** unique or primary key constraints on table "interactions" */
["interactions_constraint"]:interactions_constraint,
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
["interactions_delete_at_path_input"]: {
	debug?:string[]
},
	/** delete the array element with specified index (negative integers count from the
end). throws an error if top level container is not an array */
["interactions_delete_elem_input"]: {
	debug?:number
},
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
["interactions_delete_key_input"]: {
	debug?:string
},
	/** input type for incrementing numeric columns in table "interactions" */
["interactions_inc_input"]: {
	id?:number,
	match_score?:PartialObjects["float8"],
	user_id?:number
},
	/** input type for inserting data into table "interactions" */
["interactions_insert_input"]: {
	content?:string,
	content_type?:string,
	debug?:PartialObjects["jsonb"],
	embedding?:PartialObjects["vector"],
	events?:PartialObjects["events_arr_rel_insert_input"],
	id?:number,
	match_score?:PartialObjects["float8"],
	timestamp?:PartialObjects["timestamptz"],
	user_id?:number
},
	/** aggregate max on columns */
["interactions_max_fields"]: {
		__typename?: "interactions_max_fields";
			content?:string,
			content_type?:string,
			id?:number,
			match_score?:PartialObjects["float8"],
			timestamp?:PartialObjects["timestamptz"],
			user_id?:number
	},
	/** aggregate min on columns */
["interactions_min_fields"]: {
		__typename?: "interactions_min_fields";
			content?:string,
			content_type?:string,
			id?:number,
			match_score?:PartialObjects["float8"],
			timestamp?:PartialObjects["timestamptz"],
			user_id?:number
	},
	/** response of any mutation on the table "interactions" */
["interactions_mutation_response"]: {
		__typename?: "interactions_mutation_response";
			/** number of rows affected by the mutation */
	affected_rows?:number,
			/** data from the rows affected by the mutation */
	returning?:PartialObjects["interactions"][]
	},
	/** input type for inserting object relation for remote table "interactions" */
["interactions_obj_rel_insert_input"]: {
	data:PartialObjects["interactions_insert_input"],
	/** upsert condition */
	on_conflict?:PartialObjects["interactions_on_conflict"]
},
	/** on_conflict condition type for table "interactions" */
["interactions_on_conflict"]: {
	constraint:PartialObjects["interactions_constraint"],
	update_columns:PartialObjects["interactions_update_column"][],
	where?:PartialObjects["interactions_bool_exp"]
},
	/** Ordering options when selecting data from "interactions". */
["interactions_order_by"]: {
	content?:PartialObjects["order_by"],
	content_type?:PartialObjects["order_by"],
	debug?:PartialObjects["order_by"],
	embedding?:PartialObjects["order_by"],
	events_aggregate?:PartialObjects["events_aggregate_order_by"],
	id?:PartialObjects["order_by"],
	match_score?:PartialObjects["order_by"],
	timestamp?:PartialObjects["order_by"],
	user_id?:PartialObjects["order_by"]
},
	/** primary key columns input for table: interactions */
["interactions_pk_columns_input"]: {
	id:number
},
	/** prepend existing jsonb value of filtered columns with new jsonb value */
["interactions_prepend_input"]: {
	debug?:PartialObjects["jsonb"]
},
	/** select columns of table "interactions" */
["interactions_select_column"]:interactions_select_column,
	/** input type for updating data in table "interactions" */
["interactions_set_input"]: {
	content?:string,
	content_type?:string,
	debug?:PartialObjects["jsonb"],
	embedding?:PartialObjects["vector"],
	id?:number,
	match_score?:PartialObjects["float8"],
	timestamp?:PartialObjects["timestamptz"],
	user_id?:number
},
	/** aggregate stddev on columns */
["interactions_stddev_fields"]: {
		__typename?: "interactions_stddev_fields";
			id?:number,
			match_score?:number,
			user_id?:number
	},
	/** aggregate stddev_pop on columns */
["interactions_stddev_pop_fields"]: {
		__typename?: "interactions_stddev_pop_fields";
			id?:number,
			match_score?:number,
			user_id?:number
	},
	/** aggregate stddev_samp on columns */
["interactions_stddev_samp_fields"]: {
		__typename?: "interactions_stddev_samp_fields";
			id?:number,
			match_score?:number,
			user_id?:number
	},
	/** Streaming cursor of the table "interactions" */
["interactions_stream_cursor_input"]: {
	/** Stream column input with initial value */
	initial_value:PartialObjects["interactions_stream_cursor_value_input"],
	/** cursor ordering */
	ordering?:PartialObjects["cursor_ordering"]
},
	/** Initial value of the column from where the streaming should start */
["interactions_stream_cursor_value_input"]: {
	content?:string,
	content_type?:string,
	debug?:PartialObjects["jsonb"],
	embedding?:PartialObjects["vector"],
	id?:number,
	match_score?:PartialObjects["float8"],
	timestamp?:PartialObjects["timestamptz"],
	user_id?:number
},
	/** aggregate sum on columns */
["interactions_sum_fields"]: {
		__typename?: "interactions_sum_fields";
			id?:number,
			match_score?:PartialObjects["float8"],
			user_id?:number
	},
	/** update columns of table "interactions" */
["interactions_update_column"]:interactions_update_column,
	["interactions_updates"]: {
	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:PartialObjects["interactions_append_input"],
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:PartialObjects["interactions_delete_at_path_input"],
	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:PartialObjects["interactions_delete_elem_input"],
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:PartialObjects["interactions_delete_key_input"],
	/** increments the numeric columns with given value of the filtered values */
	_inc?:PartialObjects["interactions_inc_input"],
	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:PartialObjects["interactions_prepend_input"],
	/** sets the columns of the filtered rows to the given values */
	_set?:PartialObjects["interactions_set_input"],
	/** filter the rows which have to be updated */
	where:PartialObjects["interactions_bool_exp"]
},
	/** aggregate var_pop on columns */
["interactions_var_pop_fields"]: {
		__typename?: "interactions_var_pop_fields";
			id?:number,
			match_score?:number,
			user_id?:number
	},
	/** aggregate var_samp on columns */
["interactions_var_samp_fields"]: {
		__typename?: "interactions_var_samp_fields";
			id?:number,
			match_score?:number,
			user_id?:number
	},
	/** aggregate variance on columns */
["interactions_variance_fields"]: {
		__typename?: "interactions_variance_fields";
			id?:number,
			match_score?:number,
			user_id?:number
	},
	["jsonb"]:any,
	["jsonb_cast_exp"]: {
	String?:PartialObjects["String_comparison_exp"]
},
	/** Boolean expression to compare columns of type "jsonb". All fields are combined with logical 'AND'. */
["jsonb_comparison_exp"]: {
	_cast?:PartialObjects["jsonb_cast_exp"],
	/** is the column contained in the given json value */
	_contained_in?:PartialObjects["jsonb"],
	/** does the column contain the given json value at the top level */
	_contains?:PartialObjects["jsonb"],
	_eq?:PartialObjects["jsonb"],
	_gt?:PartialObjects["jsonb"],
	_gte?:PartialObjects["jsonb"],
	/** does the string exist as a top-level key in the column */
	_has_key?:string,
	/** do all of these strings exist as top-level keys in the column */
	_has_keys_all?:string[],
	/** do any of these strings exist as top-level keys in the column */
	_has_keys_any?:string[],
	_in?:PartialObjects["jsonb"][],
	_is_null?:boolean,
	_lt?:PartialObjects["jsonb"],
	_lte?:PartialObjects["jsonb"],
	_neq?:PartialObjects["jsonb"],
	_nin?:PartialObjects["jsonb"][]
},
	/** columns and relationships of "locations" */
["locations"]: {
		__typename?: "locations";
			id?:number,
			location?:PartialObjects["geography"],
			name?:string,
			user_id?:number
	},
	["locations_aggregate"]: {
		__typename?: "locations_aggregate";
			aggregate?:PartialObjects["locations_aggregate_fields"],
			nodes?:PartialObjects["locations"][]
	},
	["locations_aggregate_bool_exp"]: {
	count?:PartialObjects["locations_aggregate_bool_exp_count"]
},
	["locations_aggregate_bool_exp_count"]: {
	arguments?:PartialObjects["locations_select_column"][],
	distinct?:boolean,
	filter?:PartialObjects["locations_bool_exp"],
	predicate:PartialObjects["Int_comparison_exp"]
},
	/** aggregate fields of "locations" */
["locations_aggregate_fields"]: {
		__typename?: "locations_aggregate_fields";
			avg?:PartialObjects["locations_avg_fields"],
			count?:number,
			max?:PartialObjects["locations_max_fields"],
			min?:PartialObjects["locations_min_fields"],
			stddev?:PartialObjects["locations_stddev_fields"],
			stddev_pop?:PartialObjects["locations_stddev_pop_fields"],
			stddev_samp?:PartialObjects["locations_stddev_samp_fields"],
			sum?:PartialObjects["locations_sum_fields"],
			var_pop?:PartialObjects["locations_var_pop_fields"],
			var_samp?:PartialObjects["locations_var_samp_fields"],
			variance?:PartialObjects["locations_variance_fields"]
	},
	/** order by aggregate values of table "locations" */
["locations_aggregate_order_by"]: {
	avg?:PartialObjects["locations_avg_order_by"],
	count?:PartialObjects["order_by"],
	max?:PartialObjects["locations_max_order_by"],
	min?:PartialObjects["locations_min_order_by"],
	stddev?:PartialObjects["locations_stddev_order_by"],
	stddev_pop?:PartialObjects["locations_stddev_pop_order_by"],
	stddev_samp?:PartialObjects["locations_stddev_samp_order_by"],
	sum?:PartialObjects["locations_sum_order_by"],
	var_pop?:PartialObjects["locations_var_pop_order_by"],
	var_samp?:PartialObjects["locations_var_samp_order_by"],
	variance?:PartialObjects["locations_variance_order_by"]
},
	/** input type for inserting array relation for remote table "locations" */
["locations_arr_rel_insert_input"]: {
	data:PartialObjects["locations_insert_input"][],
	/** upsert condition */
	on_conflict?:PartialObjects["locations_on_conflict"]
},
	/** aggregate avg on columns */
["locations_avg_fields"]: {
		__typename?: "locations_avg_fields";
			id?:number,
			user_id?:number
	},
	/** order by avg() on columns of table "locations" */
["locations_avg_order_by"]: {
	id?:PartialObjects["order_by"],
	user_id?:PartialObjects["order_by"]
},
	/** Boolean expression to filter rows from the table "locations". All fields are combined with a logical 'AND'. */
["locations_bool_exp"]: {
	_and?:PartialObjects["locations_bool_exp"][],
	_not?:PartialObjects["locations_bool_exp"],
	_or?:PartialObjects["locations_bool_exp"][],
	id?:PartialObjects["Int_comparison_exp"],
	location?:PartialObjects["geography_comparison_exp"],
	name?:PartialObjects["String_comparison_exp"],
	user_id?:PartialObjects["Int_comparison_exp"]
},
	/** unique or primary key constraints on table "locations" */
["locations_constraint"]:locations_constraint,
	/** input type for incrementing numeric columns in table "locations" */
["locations_inc_input"]: {
	id?:number,
	user_id?:number
},
	/** input type for inserting data into table "locations" */
["locations_insert_input"]: {
	id?:number,
	location?:PartialObjects["geography"],
	name?:string,
	user_id?:number
},
	/** aggregate max on columns */
["locations_max_fields"]: {
		__typename?: "locations_max_fields";
			id?:number,
			name?:string,
			user_id?:number
	},
	/** order by max() on columns of table "locations" */
["locations_max_order_by"]: {
	id?:PartialObjects["order_by"],
	name?:PartialObjects["order_by"],
	user_id?:PartialObjects["order_by"]
},
	/** aggregate min on columns */
["locations_min_fields"]: {
		__typename?: "locations_min_fields";
			id?:number,
			name?:string,
			user_id?:number
	},
	/** order by min() on columns of table "locations" */
["locations_min_order_by"]: {
	id?:PartialObjects["order_by"],
	name?:PartialObjects["order_by"],
	user_id?:PartialObjects["order_by"]
},
	/** response of any mutation on the table "locations" */
["locations_mutation_response"]: {
		__typename?: "locations_mutation_response";
			/** number of rows affected by the mutation */
	affected_rows?:number,
			/** data from the rows affected by the mutation */
	returning?:PartialObjects["locations"][]
	},
	/** on_conflict condition type for table "locations" */
["locations_on_conflict"]: {
	constraint:PartialObjects["locations_constraint"],
	update_columns:PartialObjects["locations_update_column"][],
	where?:PartialObjects["locations_bool_exp"]
},
	/** Ordering options when selecting data from "locations". */
["locations_order_by"]: {
	id?:PartialObjects["order_by"],
	location?:PartialObjects["order_by"],
	name?:PartialObjects["order_by"],
	user_id?:PartialObjects["order_by"]
},
	/** primary key columns input for table: locations */
["locations_pk_columns_input"]: {
	id:number
},
	/** select columns of table "locations" */
["locations_select_column"]:locations_select_column,
	/** input type for updating data in table "locations" */
["locations_set_input"]: {
	id?:number,
	location?:PartialObjects["geography"],
	name?:string,
	user_id?:number
},
	/** aggregate stddev on columns */
["locations_stddev_fields"]: {
		__typename?: "locations_stddev_fields";
			id?:number,
			user_id?:number
	},
	/** order by stddev() on columns of table "locations" */
["locations_stddev_order_by"]: {
	id?:PartialObjects["order_by"],
	user_id?:PartialObjects["order_by"]
},
	/** aggregate stddev_pop on columns */
["locations_stddev_pop_fields"]: {
		__typename?: "locations_stddev_pop_fields";
			id?:number,
			user_id?:number
	},
	/** order by stddev_pop() on columns of table "locations" */
["locations_stddev_pop_order_by"]: {
	id?:PartialObjects["order_by"],
	user_id?:PartialObjects["order_by"]
},
	/** aggregate stddev_samp on columns */
["locations_stddev_samp_fields"]: {
		__typename?: "locations_stddev_samp_fields";
			id?:number,
			user_id?:number
	},
	/** order by stddev_samp() on columns of table "locations" */
["locations_stddev_samp_order_by"]: {
	id?:PartialObjects["order_by"],
	user_id?:PartialObjects["order_by"]
},
	/** Streaming cursor of the table "locations" */
["locations_stream_cursor_input"]: {
	/** Stream column input with initial value */
	initial_value:PartialObjects["locations_stream_cursor_value_input"],
	/** cursor ordering */
	ordering?:PartialObjects["cursor_ordering"]
},
	/** Initial value of the column from where the streaming should start */
["locations_stream_cursor_value_input"]: {
	id?:number,
	location?:PartialObjects["geography"],
	name?:string,
	user_id?:number
},
	/** aggregate sum on columns */
["locations_sum_fields"]: {
		__typename?: "locations_sum_fields";
			id?:number,
			user_id?:number
	},
	/** order by sum() on columns of table "locations" */
["locations_sum_order_by"]: {
	id?:PartialObjects["order_by"],
	user_id?:PartialObjects["order_by"]
},
	/** update columns of table "locations" */
["locations_update_column"]:locations_update_column,
	["locations_updates"]: {
	/** increments the numeric columns with given value of the filtered values */
	_inc?:PartialObjects["locations_inc_input"],
	/** sets the columns of the filtered rows to the given values */
	_set?:PartialObjects["locations_set_input"],
	/** filter the rows which have to be updated */
	where:PartialObjects["locations_bool_exp"]
},
	/** aggregate var_pop on columns */
["locations_var_pop_fields"]: {
		__typename?: "locations_var_pop_fields";
			id?:number,
			user_id?:number
	},
	/** order by var_pop() on columns of table "locations" */
["locations_var_pop_order_by"]: {
	id?:PartialObjects["order_by"],
	user_id?:PartialObjects["order_by"]
},
	/** aggregate var_samp on columns */
["locations_var_samp_fields"]: {
		__typename?: "locations_var_samp_fields";
			id?:number,
			user_id?:number
	},
	/** order by var_samp() on columns of table "locations" */
["locations_var_samp_order_by"]: {
	id?:PartialObjects["order_by"],
	user_id?:PartialObjects["order_by"]
},
	/** aggregate variance on columns */
["locations_variance_fields"]: {
		__typename?: "locations_variance_fields";
			id?:number,
			user_id?:number
	},
	/** order by variance() on columns of table "locations" */
["locations_variance_order_by"]: {
	id?:PartialObjects["order_by"],
	user_id?:PartialObjects["order_by"]
},
	["match_interactions_args"]: {
	match_threshold?:PartialObjects["float8"],
	query_embedding?:PartialObjects["vector"],
	target_user_id?:number
},
	/** mutation root */
["mutation_root"]: {
		__typename?: "mutation_root";
			/** delete data from the table: "associations" */
	delete_associations?:PartialObjects["associations_mutation_response"],
			/** delete single row from the table: "associations" */
	delete_associations_by_pk?:PartialObjects["associations"],
			/** delete data from the table: "event_tag" */
	delete_event_tag?:PartialObjects["event_tag_mutation_response"],
			/** delete single row from the table: "event_tag" */
	delete_event_tag_by_pk?:PartialObjects["event_tag"],
			/** delete data from the table: "event_types" */
	delete_event_types?:PartialObjects["event_types_mutation_response"],
			/** delete single row from the table: "event_types" */
	delete_event_types_by_pk?:PartialObjects["event_types"],
			/** delete data from the table: "events" */
	delete_events?:PartialObjects["events_mutation_response"],
			/** delete single row from the table: "events" */
	delete_events_by_pk?:PartialObjects["events"],
			/** delete data from the table: "goals" */
	delete_goals?:PartialObjects["goals_mutation_response"],
			/** delete single row from the table: "goals" */
	delete_goals_by_pk?:PartialObjects["goals"],
			/** delete data from the table: "interactions" */
	delete_interactions?:PartialObjects["interactions_mutation_response"],
			/** delete single row from the table: "interactions" */
	delete_interactions_by_pk?:PartialObjects["interactions"],
			/** delete data from the table: "locations" */
	delete_locations?:PartialObjects["locations_mutation_response"],
			/** delete single row from the table: "locations" */
	delete_locations_by_pk?:PartialObjects["locations"],
			/** delete data from the table: "object_types" */
	delete_object_types?:PartialObjects["object_types_mutation_response"],
			/** delete single row from the table: "object_types" */
	delete_object_types_by_pk?:PartialObjects["object_types"],
			/** delete data from the table: "objects" */
	delete_objects?:PartialObjects["objects_mutation_response"],
			/** delete single row from the table: "objects" */
	delete_objects_by_pk?:PartialObjects["objects"],
			/** delete data from the table: "todos" */
	delete_todos?:PartialObjects["todos_mutation_response"],
			/** delete single row from the table: "todos" */
	delete_todos_by_pk?:PartialObjects["todos"],
			/** delete data from the table: "users" */
	delete_users?:PartialObjects["users_mutation_response"],
			/** delete single row from the table: "users" */
	delete_users_by_pk?:PartialObjects["users"],
			/** insert data into the table: "associations" */
	insert_associations?:PartialObjects["associations_mutation_response"],
			/** insert a single row into the table: "associations" */
	insert_associations_one?:PartialObjects["associations"],
			/** insert data into the table: "event_tag" */
	insert_event_tag?:PartialObjects["event_tag_mutation_response"],
			/** insert a single row into the table: "event_tag" */
	insert_event_tag_one?:PartialObjects["event_tag"],
			/** insert data into the table: "event_types" */
	insert_event_types?:PartialObjects["event_types_mutation_response"],
			/** insert a single row into the table: "event_types" */
	insert_event_types_one?:PartialObjects["event_types"],
			/** insert data into the table: "events" */
	insert_events?:PartialObjects["events_mutation_response"],
			/** insert a single row into the table: "events" */
	insert_events_one?:PartialObjects["events"],
			/** insert data into the table: "goals" */
	insert_goals?:PartialObjects["goals_mutation_response"],
			/** insert a single row into the table: "goals" */
	insert_goals_one?:PartialObjects["goals"],
			/** insert data into the table: "interactions" */
	insert_interactions?:PartialObjects["interactions_mutation_response"],
			/** insert a single row into the table: "interactions" */
	insert_interactions_one?:PartialObjects["interactions"],
			/** insert data into the table: "locations" */
	insert_locations?:PartialObjects["locations_mutation_response"],
			/** insert a single row into the table: "locations" */
	insert_locations_one?:PartialObjects["locations"],
			/** insert data into the table: "object_types" */
	insert_object_types?:PartialObjects["object_types_mutation_response"],
			/** insert a single row into the table: "object_types" */
	insert_object_types_one?:PartialObjects["object_types"],
			/** insert data into the table: "objects" */
	insert_objects?:PartialObjects["objects_mutation_response"],
			/** insert a single row into the table: "objects" */
	insert_objects_one?:PartialObjects["objects"],
			/** insert data into the table: "todos" */
	insert_todos?:PartialObjects["todos_mutation_response"],
			/** insert a single row into the table: "todos" */
	insert_todos_one?:PartialObjects["todos"],
			/** insert data into the table: "users" */
	insert_users?:PartialObjects["users_mutation_response"],
			/** insert a single row into the table: "users" */
	insert_users_one?:PartialObjects["users"],
			/** update data of the table: "associations" */
	update_associations?:PartialObjects["associations_mutation_response"],
			/** update single row of the table: "associations" */
	update_associations_by_pk?:PartialObjects["associations"],
			/** update multiples rows of table: "associations" */
	update_associations_many?:(PartialObjects["associations_mutation_response"] | undefined)[],
			/** update data of the table: "event_tag" */
	update_event_tag?:PartialObjects["event_tag_mutation_response"],
			/** update single row of the table: "event_tag" */
	update_event_tag_by_pk?:PartialObjects["event_tag"],
			/** update multiples rows of table: "event_tag" */
	update_event_tag_many?:(PartialObjects["event_tag_mutation_response"] | undefined)[],
			/** update data of the table: "event_types" */
	update_event_types?:PartialObjects["event_types_mutation_response"],
			/** update single row of the table: "event_types" */
	update_event_types_by_pk?:PartialObjects["event_types"],
			/** update multiples rows of table: "event_types" */
	update_event_types_many?:(PartialObjects["event_types_mutation_response"] | undefined)[],
			/** update data of the table: "events" */
	update_events?:PartialObjects["events_mutation_response"],
			/** update single row of the table: "events" */
	update_events_by_pk?:PartialObjects["events"],
			/** update multiples rows of table: "events" */
	update_events_many?:(PartialObjects["events_mutation_response"] | undefined)[],
			/** update data of the table: "goals" */
	update_goals?:PartialObjects["goals_mutation_response"],
			/** update single row of the table: "goals" */
	update_goals_by_pk?:PartialObjects["goals"],
			/** update multiples rows of table: "goals" */
	update_goals_many?:(PartialObjects["goals_mutation_response"] | undefined)[],
			/** update data of the table: "interactions" */
	update_interactions?:PartialObjects["interactions_mutation_response"],
			/** update single row of the table: "interactions" */
	update_interactions_by_pk?:PartialObjects["interactions"],
			/** update multiples rows of table: "interactions" */
	update_interactions_many?:(PartialObjects["interactions_mutation_response"] | undefined)[],
			/** update data of the table: "locations" */
	update_locations?:PartialObjects["locations_mutation_response"],
			/** update single row of the table: "locations" */
	update_locations_by_pk?:PartialObjects["locations"],
			/** update multiples rows of table: "locations" */
	update_locations_many?:(PartialObjects["locations_mutation_response"] | undefined)[],
			/** update data of the table: "object_types" */
	update_object_types?:PartialObjects["object_types_mutation_response"],
			/** update single row of the table: "object_types" */
	update_object_types_by_pk?:PartialObjects["object_types"],
			/** update multiples rows of table: "object_types" */
	update_object_types_many?:(PartialObjects["object_types_mutation_response"] | undefined)[],
			/** update data of the table: "objects" */
	update_objects?:PartialObjects["objects_mutation_response"],
			/** update single row of the table: "objects" */
	update_objects_by_pk?:PartialObjects["objects"],
			/** update multiples rows of table: "objects" */
	update_objects_many?:(PartialObjects["objects_mutation_response"] | undefined)[],
			/** update data of the table: "todos" */
	update_todos?:PartialObjects["todos_mutation_response"],
			/** update single row of the table: "todos" */
	update_todos_by_pk?:PartialObjects["todos"],
			/** update multiples rows of table: "todos" */
	update_todos_many?:(PartialObjects["todos_mutation_response"] | undefined)[],
			/** update data of the table: "users" */
	update_users?:PartialObjects["users_mutation_response"],
			/** update single row of the table: "users" */
	update_users_by_pk?:PartialObjects["users"],
			/** update multiples rows of table: "users" */
	update_users_many?:(PartialObjects["users_mutation_response"] | undefined)[]
	},
	/** columns and relationships of "object_types" */
["object_types"]: {
		__typename?: "object_types";
			id?:string,
			metadata?:PartialObjects["jsonb"]
	},
	/** aggregated selection of "object_types" */
["object_types_aggregate"]: {
		__typename?: "object_types_aggregate";
			aggregate?:PartialObjects["object_types_aggregate_fields"],
			nodes?:PartialObjects["object_types"][]
	},
	/** aggregate fields of "object_types" */
["object_types_aggregate_fields"]: {
		__typename?: "object_types_aggregate_fields";
			count?:number,
			max?:PartialObjects["object_types_max_fields"],
			min?:PartialObjects["object_types_min_fields"]
	},
	/** append existing jsonb value of filtered columns with new jsonb value */
["object_types_append_input"]: {
	metadata?:PartialObjects["jsonb"]
},
	/** Boolean expression to filter rows from the table "object_types". All fields are combined with a logical 'AND'. */
["object_types_bool_exp"]: {
	_and?:PartialObjects["object_types_bool_exp"][],
	_not?:PartialObjects["object_types_bool_exp"],
	_or?:PartialObjects["object_types_bool_exp"][],
	id?:PartialObjects["String_comparison_exp"],
	metadata?:PartialObjects["jsonb_comparison_exp"]
},
	/** unique or primary key constraints on table "object_types" */
["object_types_constraint"]:object_types_constraint,
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
["object_types_delete_at_path_input"]: {
	metadata?:string[]
},
	/** delete the array element with specified index (negative integers count from the
end). throws an error if top level container is not an array */
["object_types_delete_elem_input"]: {
	metadata?:number
},
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
["object_types_delete_key_input"]: {
	metadata?:string
},
	/** input type for inserting data into table "object_types" */
["object_types_insert_input"]: {
	id?:string,
	metadata?:PartialObjects["jsonb"]
},
	/** aggregate max on columns */
["object_types_max_fields"]: {
		__typename?: "object_types_max_fields";
			id?:string
	},
	/** aggregate min on columns */
["object_types_min_fields"]: {
		__typename?: "object_types_min_fields";
			id?:string
	},
	/** response of any mutation on the table "object_types" */
["object_types_mutation_response"]: {
		__typename?: "object_types_mutation_response";
			/** number of rows affected by the mutation */
	affected_rows?:number,
			/** data from the rows affected by the mutation */
	returning?:PartialObjects["object_types"][]
	},
	/** on_conflict condition type for table "object_types" */
["object_types_on_conflict"]: {
	constraint:PartialObjects["object_types_constraint"],
	update_columns:PartialObjects["object_types_update_column"][],
	where?:PartialObjects["object_types_bool_exp"]
},
	/** Ordering options when selecting data from "object_types". */
["object_types_order_by"]: {
	id?:PartialObjects["order_by"],
	metadata?:PartialObjects["order_by"]
},
	/** primary key columns input for table: object_types */
["object_types_pk_columns_input"]: {
	id:string
},
	/** prepend existing jsonb value of filtered columns with new jsonb value */
["object_types_prepend_input"]: {
	metadata?:PartialObjects["jsonb"]
},
	/** select columns of table "object_types" */
["object_types_select_column"]:object_types_select_column,
	/** input type for updating data in table "object_types" */
["object_types_set_input"]: {
	id?:string,
	metadata?:PartialObjects["jsonb"]
},
	/** Streaming cursor of the table "object_types" */
["object_types_stream_cursor_input"]: {
	/** Stream column input with initial value */
	initial_value:PartialObjects["object_types_stream_cursor_value_input"],
	/** cursor ordering */
	ordering?:PartialObjects["cursor_ordering"]
},
	/** Initial value of the column from where the streaming should start */
["object_types_stream_cursor_value_input"]: {
	id?:string,
	metadata?:PartialObjects["jsonb"]
},
	/** update columns of table "object_types" */
["object_types_update_column"]:object_types_update_column,
	["object_types_updates"]: {
	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:PartialObjects["object_types_append_input"],
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:PartialObjects["object_types_delete_at_path_input"],
	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:PartialObjects["object_types_delete_elem_input"],
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:PartialObjects["object_types_delete_key_input"],
	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:PartialObjects["object_types_prepend_input"],
	/** sets the columns of the filtered rows to the given values */
	_set?:PartialObjects["object_types_set_input"],
	/** filter the rows which have to be updated */
	where:PartialObjects["object_types_bool_exp"]
},
	/** columns and relationships of "objects" */
["objects"]: {
		__typename?: "objects";
			id?:number,
			name?:string,
			object_type?:string
	},
	/** aggregated selection of "objects" */
["objects_aggregate"]: {
		__typename?: "objects_aggregate";
			aggregate?:PartialObjects["objects_aggregate_fields"],
			nodes?:PartialObjects["objects"][]
	},
	/** aggregate fields of "objects" */
["objects_aggregate_fields"]: {
		__typename?: "objects_aggregate_fields";
			avg?:PartialObjects["objects_avg_fields"],
			count?:number,
			max?:PartialObjects["objects_max_fields"],
			min?:PartialObjects["objects_min_fields"],
			stddev?:PartialObjects["objects_stddev_fields"],
			stddev_pop?:PartialObjects["objects_stddev_pop_fields"],
			stddev_samp?:PartialObjects["objects_stddev_samp_fields"],
			sum?:PartialObjects["objects_sum_fields"],
			var_pop?:PartialObjects["objects_var_pop_fields"],
			var_samp?:PartialObjects["objects_var_samp_fields"],
			variance?:PartialObjects["objects_variance_fields"]
	},
	/** aggregate avg on columns */
["objects_avg_fields"]: {
		__typename?: "objects_avg_fields";
			id?:number
	},
	/** Boolean expression to filter rows from the table "objects". All fields are combined with a logical 'AND'. */
["objects_bool_exp"]: {
	_and?:PartialObjects["objects_bool_exp"][],
	_not?:PartialObjects["objects_bool_exp"],
	_or?:PartialObjects["objects_bool_exp"][],
	id?:PartialObjects["Int_comparison_exp"],
	name?:PartialObjects["String_comparison_exp"],
	object_type?:PartialObjects["String_comparison_exp"]
},
	/** unique or primary key constraints on table "objects" */
["objects_constraint"]:objects_constraint,
	/** input type for incrementing numeric columns in table "objects" */
["objects_inc_input"]: {
	id?:number
},
	/** input type for inserting data into table "objects" */
["objects_insert_input"]: {
	id?:number,
	name?:string,
	object_type?:string
},
	/** aggregate max on columns */
["objects_max_fields"]: {
		__typename?: "objects_max_fields";
			id?:number,
			name?:string,
			object_type?:string
	},
	/** aggregate min on columns */
["objects_min_fields"]: {
		__typename?: "objects_min_fields";
			id?:number,
			name?:string,
			object_type?:string
	},
	/** response of any mutation on the table "objects" */
["objects_mutation_response"]: {
		__typename?: "objects_mutation_response";
			/** number of rows affected by the mutation */
	affected_rows?:number,
			/** data from the rows affected by the mutation */
	returning?:PartialObjects["objects"][]
	},
	/** on_conflict condition type for table "objects" */
["objects_on_conflict"]: {
	constraint:PartialObjects["objects_constraint"],
	update_columns:PartialObjects["objects_update_column"][],
	where?:PartialObjects["objects_bool_exp"]
},
	/** Ordering options when selecting data from "objects". */
["objects_order_by"]: {
	id?:PartialObjects["order_by"],
	name?:PartialObjects["order_by"],
	object_type?:PartialObjects["order_by"]
},
	/** primary key columns input for table: objects */
["objects_pk_columns_input"]: {
	id:number
},
	/** select columns of table "objects" */
["objects_select_column"]:objects_select_column,
	/** input type for updating data in table "objects" */
["objects_set_input"]: {
	id?:number,
	name?:string,
	object_type?:string
},
	/** aggregate stddev on columns */
["objects_stddev_fields"]: {
		__typename?: "objects_stddev_fields";
			id?:number
	},
	/** aggregate stddev_pop on columns */
["objects_stddev_pop_fields"]: {
		__typename?: "objects_stddev_pop_fields";
			id?:number
	},
	/** aggregate stddev_samp on columns */
["objects_stddev_samp_fields"]: {
		__typename?: "objects_stddev_samp_fields";
			id?:number
	},
	/** Streaming cursor of the table "objects" */
["objects_stream_cursor_input"]: {
	/** Stream column input with initial value */
	initial_value:PartialObjects["objects_stream_cursor_value_input"],
	/** cursor ordering */
	ordering?:PartialObjects["cursor_ordering"]
},
	/** Initial value of the column from where the streaming should start */
["objects_stream_cursor_value_input"]: {
	id?:number,
	name?:string,
	object_type?:string
},
	/** aggregate sum on columns */
["objects_sum_fields"]: {
		__typename?: "objects_sum_fields";
			id?:number
	},
	/** update columns of table "objects" */
["objects_update_column"]:objects_update_column,
	["objects_updates"]: {
	/** increments the numeric columns with given value of the filtered values */
	_inc?:PartialObjects["objects_inc_input"],
	/** sets the columns of the filtered rows to the given values */
	_set?:PartialObjects["objects_set_input"],
	/** filter the rows which have to be updated */
	where:PartialObjects["objects_bool_exp"]
},
	/** aggregate var_pop on columns */
["objects_var_pop_fields"]: {
		__typename?: "objects_var_pop_fields";
			id?:number
	},
	/** aggregate var_samp on columns */
["objects_var_samp_fields"]: {
		__typename?: "objects_var_samp_fields";
			id?:number
	},
	/** aggregate variance on columns */
["objects_variance_fields"]: {
		__typename?: "objects_variance_fields";
			id?:number
	},
	/** column ordering options */
["order_by"]:order_by,
	["query_root"]: {
		__typename?: "query_root";
			/** fetch data from the table: "associations" */
	associations?:PartialObjects["associations"][],
			/** fetch aggregated fields from the table: "associations" */
	associations_aggregate?:PartialObjects["associations_aggregate"],
			/** fetch data from the table: "associations" using primary key columns */
	associations_by_pk?:PartialObjects["associations"],
			/** execute function "closest_user_location" which returns "locations" */
	closest_user_location?:PartialObjects["locations"][],
			/** execute function "closest_user_location" and query aggregates on result of table type "locations" */
	closest_user_location_aggregate?:PartialObjects["locations_aggregate"],
			/** fetch data from the table: "event_tag" */
	event_tag?:PartialObjects["event_tag"][],
			/** fetch aggregated fields from the table: "event_tag" */
	event_tag_aggregate?:PartialObjects["event_tag_aggregate"],
			/** fetch data from the table: "event_tag" using primary key columns */
	event_tag_by_pk?:PartialObjects["event_tag"],
			/** fetch data from the table: "event_types" */
	event_types?:PartialObjects["event_types"][],
			/** fetch aggregated fields from the table: "event_types" */
	event_types_aggregate?:PartialObjects["event_types_aggregate"],
			/** fetch data from the table: "event_types" using primary key columns */
	event_types_by_pk?:PartialObjects["event_types"],
			/** An array relationship */
	events?:PartialObjects["events"][],
			/** An aggregate relationship */
	events_aggregate?:PartialObjects["events_aggregate"],
			/** fetch data from the table: "events" using primary key columns */
	events_by_pk?:PartialObjects["events"],
			/** execute function "fetch_associations" which returns "associations" */
	fetch_associations?:PartialObjects["associations"][],
			/** execute function "fetch_associations" and query aggregates on result of table type "associations" */
	fetch_associations_aggregate?:PartialObjects["associations_aggregate"],
			/** fetch data from the table: "goals" */
	goals?:PartialObjects["goals"][],
			/** fetch aggregated fields from the table: "goals" */
	goals_aggregate?:PartialObjects["goals_aggregate"],
			/** fetch data from the table: "goals" using primary key columns */
	goals_by_pk?:PartialObjects["goals"],
			/** fetch data from the table: "interactions" */
	interactions?:PartialObjects["interactions"][],
			/** fetch aggregated fields from the table: "interactions" */
	interactions_aggregate?:PartialObjects["interactions_aggregate"],
			/** fetch data from the table: "interactions" using primary key columns */
	interactions_by_pk?:PartialObjects["interactions"],
			/** An array relationship */
	locations?:PartialObjects["locations"][],
			/** An aggregate relationship */
	locations_aggregate?:PartialObjects["locations_aggregate"],
			/** fetch data from the table: "locations" using primary key columns */
	locations_by_pk?:PartialObjects["locations"],
			/** execute function "match_interactions" which returns "interactions" */
	match_interactions?:PartialObjects["interactions"][],
			/** execute function "match_interactions" and query aggregates on result of table type "interactions" */
	match_interactions_aggregate?:PartialObjects["interactions_aggregate"],
			/** fetch data from the table: "object_types" */
	object_types?:PartialObjects["object_types"][],
			/** fetch aggregated fields from the table: "object_types" */
	object_types_aggregate?:PartialObjects["object_types_aggregate"],
			/** fetch data from the table: "object_types" using primary key columns */
	object_types_by_pk?:PartialObjects["object_types"],
			/** fetch data from the table: "objects" */
	objects?:PartialObjects["objects"][],
			/** fetch aggregated fields from the table: "objects" */
	objects_aggregate?:PartialObjects["objects_aggregate"],
			/** fetch data from the table: "objects" using primary key columns */
	objects_by_pk?:PartialObjects["objects"],
			/** fetch data from the table: "todos" */
	todos?:PartialObjects["todos"][],
			/** fetch aggregated fields from the table: "todos" */
	todos_aggregate?:PartialObjects["todos_aggregate"],
			/** fetch data from the table: "todos" using primary key columns */
	todos_by_pk?:PartialObjects["todos"],
			/** fetch data from the table: "users" */
	users?:PartialObjects["users"][],
			/** fetch aggregated fields from the table: "users" */
	users_aggregate?:PartialObjects["users_aggregate"],
			/** fetch data from the table: "users" using primary key columns */
	users_by_pk?:PartialObjects["users"]
	},
	["st_d_within_geography_input"]: {
	distance:number,
	from:PartialObjects["geography"],
	use_spheroid?:boolean
},
	["st_d_within_input"]: {
	distance:number,
	from:PartialObjects["geometry"]
},
	/** Boolean expression to compare columns of type "String". All fields are combined with logical 'AND'. */
["String_comparison_exp"]: {
	_eq?:string,
	_gt?:string,
	_gte?:string,
	/** does the column match the given case-insensitive pattern */
	_ilike?:string,
	_in?:string[],
	/** does the column match the given POSIX regular expression, case insensitive */
	_iregex?:string,
	_is_null?:boolean,
	/** does the column match the given pattern */
	_like?:string,
	_lt?:string,
	_lte?:string,
	_neq?:string,
	/** does the column NOT match the given case-insensitive pattern */
	_nilike?:string,
	_nin?:string[],
	/** does the column NOT match the given POSIX regular expression, case insensitive */
	_niregex?:string,
	/** does the column NOT match the given pattern */
	_nlike?:string,
	/** does the column NOT match the given POSIX regular expression, case sensitive */
	_nregex?:string,
	/** does the column NOT match the given SQL regular expression */
	_nsimilar?:string,
	/** does the column match the given POSIX regular expression, case sensitive */
	_regex?:string,
	/** does the column match the given SQL regular expression */
	_similar?:string
},
	["subscription_root"]: {
		__typename?: "subscription_root";
			/** fetch data from the table: "associations" */
	associations?:PartialObjects["associations"][],
			/** fetch aggregated fields from the table: "associations" */
	associations_aggregate?:PartialObjects["associations_aggregate"],
			/** fetch data from the table: "associations" using primary key columns */
	associations_by_pk?:PartialObjects["associations"],
			/** fetch data from the table in a streaming manner: "associations" */
	associations_stream?:PartialObjects["associations"][],
			/** execute function "closest_user_location" which returns "locations" */
	closest_user_location?:PartialObjects["locations"][],
			/** execute function "closest_user_location" and query aggregates on result of table type "locations" */
	closest_user_location_aggregate?:PartialObjects["locations_aggregate"],
			/** fetch data from the table: "event_tag" */
	event_tag?:PartialObjects["event_tag"][],
			/** fetch aggregated fields from the table: "event_tag" */
	event_tag_aggregate?:PartialObjects["event_tag_aggregate"],
			/** fetch data from the table: "event_tag" using primary key columns */
	event_tag_by_pk?:PartialObjects["event_tag"],
			/** fetch data from the table in a streaming manner: "event_tag" */
	event_tag_stream?:PartialObjects["event_tag"][],
			/** fetch data from the table: "event_types" */
	event_types?:PartialObjects["event_types"][],
			/** fetch aggregated fields from the table: "event_types" */
	event_types_aggregate?:PartialObjects["event_types_aggregate"],
			/** fetch data from the table: "event_types" using primary key columns */
	event_types_by_pk?:PartialObjects["event_types"],
			/** fetch data from the table in a streaming manner: "event_types" */
	event_types_stream?:PartialObjects["event_types"][],
			/** An array relationship */
	events?:PartialObjects["events"][],
			/** An aggregate relationship */
	events_aggregate?:PartialObjects["events_aggregate"],
			/** fetch data from the table: "events" using primary key columns */
	events_by_pk?:PartialObjects["events"],
			/** fetch data from the table in a streaming manner: "events" */
	events_stream?:PartialObjects["events"][],
			/** execute function "fetch_associations" which returns "associations" */
	fetch_associations?:PartialObjects["associations"][],
			/** execute function "fetch_associations" and query aggregates on result of table type "associations" */
	fetch_associations_aggregate?:PartialObjects["associations_aggregate"],
			/** fetch data from the table: "goals" */
	goals?:PartialObjects["goals"][],
			/** fetch aggregated fields from the table: "goals" */
	goals_aggregate?:PartialObjects["goals_aggregate"],
			/** fetch data from the table: "goals" using primary key columns */
	goals_by_pk?:PartialObjects["goals"],
			/** fetch data from the table in a streaming manner: "goals" */
	goals_stream?:PartialObjects["goals"][],
			/** fetch data from the table: "interactions" */
	interactions?:PartialObjects["interactions"][],
			/** fetch aggregated fields from the table: "interactions" */
	interactions_aggregate?:PartialObjects["interactions_aggregate"],
			/** fetch data from the table: "interactions" using primary key columns */
	interactions_by_pk?:PartialObjects["interactions"],
			/** fetch data from the table in a streaming manner: "interactions" */
	interactions_stream?:PartialObjects["interactions"][],
			/** An array relationship */
	locations?:PartialObjects["locations"][],
			/** An aggregate relationship */
	locations_aggregate?:PartialObjects["locations_aggregate"],
			/** fetch data from the table: "locations" using primary key columns */
	locations_by_pk?:PartialObjects["locations"],
			/** fetch data from the table in a streaming manner: "locations" */
	locations_stream?:PartialObjects["locations"][],
			/** execute function "match_interactions" which returns "interactions" */
	match_interactions?:PartialObjects["interactions"][],
			/** execute function "match_interactions" and query aggregates on result of table type "interactions" */
	match_interactions_aggregate?:PartialObjects["interactions_aggregate"],
			/** fetch data from the table: "object_types" */
	object_types?:PartialObjects["object_types"][],
			/** fetch aggregated fields from the table: "object_types" */
	object_types_aggregate?:PartialObjects["object_types_aggregate"],
			/** fetch data from the table: "object_types" using primary key columns */
	object_types_by_pk?:PartialObjects["object_types"],
			/** fetch data from the table in a streaming manner: "object_types" */
	object_types_stream?:PartialObjects["object_types"][],
			/** fetch data from the table: "objects" */
	objects?:PartialObjects["objects"][],
			/** fetch aggregated fields from the table: "objects" */
	objects_aggregate?:PartialObjects["objects_aggregate"],
			/** fetch data from the table: "objects" using primary key columns */
	objects_by_pk?:PartialObjects["objects"],
			/** fetch data from the table in a streaming manner: "objects" */
	objects_stream?:PartialObjects["objects"][],
			/** fetch data from the table: "todos" */
	todos?:PartialObjects["todos"][],
			/** fetch aggregated fields from the table: "todos" */
	todos_aggregate?:PartialObjects["todos_aggregate"],
			/** fetch data from the table: "todos" using primary key columns */
	todos_by_pk?:PartialObjects["todos"],
			/** fetch data from the table in a streaming manner: "todos" */
	todos_stream?:PartialObjects["todos"][],
			/** fetch data from the table: "users" */
	users?:PartialObjects["users"][],
			/** fetch aggregated fields from the table: "users" */
	users_aggregate?:PartialObjects["users_aggregate"],
			/** fetch data from the table: "users" using primary key columns */
	users_by_pk?:PartialObjects["users"],
			/** fetch data from the table in a streaming manner: "users" */
	users_stream?:PartialObjects["users"][]
	},
	["timestamp"]:any,
	/** Boolean expression to compare columns of type "timestamp". All fields are combined with logical 'AND'. */
["timestamp_comparison_exp"]: {
	_eq?:PartialObjects["timestamp"],
	_gt?:PartialObjects["timestamp"],
	_gte?:PartialObjects["timestamp"],
	_in?:PartialObjects["timestamp"][],
	_is_null?:boolean,
	_lt?:PartialObjects["timestamp"],
	_lte?:PartialObjects["timestamp"],
	_neq?:PartialObjects["timestamp"],
	_nin?:PartialObjects["timestamp"][]
},
	["timestamptz"]:any,
	/** Boolean expression to compare columns of type "timestamptz". All fields are combined with logical 'AND'. */
["timestamptz_comparison_exp"]: {
	_eq?:PartialObjects["timestamptz"],
	_gt?:PartialObjects["timestamptz"],
	_gte?:PartialObjects["timestamptz"],
	_in?:PartialObjects["timestamptz"][],
	_is_null?:boolean,
	_lt?:PartialObjects["timestamptz"],
	_lte?:PartialObjects["timestamptz"],
	_neq?:PartialObjects["timestamptz"],
	_nin?:PartialObjects["timestamptz"][]
},
	/** columns and relationships of "todos" */
["todos"]: {
		__typename?: "todos";
			current_count?:number,
			done_as_expected?:boolean,
			due?:PartialObjects["timestamptz"],
			/** An object relationship */
	goal?:PartialObjects["goals"],
			goal_id?:number,
			id?:number,
			name?:string,
			status?:string,
			updated?:PartialObjects["timestamptz"],
			/** An object relationship */
	user?:PartialObjects["users"],
			user_id?:number
	},
	/** aggregated selection of "todos" */
["todos_aggregate"]: {
		__typename?: "todos_aggregate";
			aggregate?:PartialObjects["todos_aggregate_fields"],
			nodes?:PartialObjects["todos"][]
	},
	/** aggregate fields of "todos" */
["todos_aggregate_fields"]: {
		__typename?: "todos_aggregate_fields";
			avg?:PartialObjects["todos_avg_fields"],
			count?:number,
			max?:PartialObjects["todos_max_fields"],
			min?:PartialObjects["todos_min_fields"],
			stddev?:PartialObjects["todos_stddev_fields"],
			stddev_pop?:PartialObjects["todos_stddev_pop_fields"],
			stddev_samp?:PartialObjects["todos_stddev_samp_fields"],
			sum?:PartialObjects["todos_sum_fields"],
			var_pop?:PartialObjects["todos_var_pop_fields"],
			var_samp?:PartialObjects["todos_var_samp_fields"],
			variance?:PartialObjects["todos_variance_fields"]
	},
	/** aggregate avg on columns */
["todos_avg_fields"]: {
		__typename?: "todos_avg_fields";
			current_count?:number,
			goal_id?:number,
			id?:number,
			user_id?:number
	},
	/** Boolean expression to filter rows from the table "todos". All fields are combined with a logical 'AND'. */
["todos_bool_exp"]: {
	_and?:PartialObjects["todos_bool_exp"][],
	_not?:PartialObjects["todos_bool_exp"],
	_or?:PartialObjects["todos_bool_exp"][],
	current_count?:PartialObjects["Int_comparison_exp"],
	done_as_expected?:PartialObjects["Boolean_comparison_exp"],
	due?:PartialObjects["timestamptz_comparison_exp"],
	goal?:PartialObjects["goals_bool_exp"],
	goal_id?:PartialObjects["Int_comparison_exp"],
	id?:PartialObjects["Int_comparison_exp"],
	name?:PartialObjects["String_comparison_exp"],
	status?:PartialObjects["String_comparison_exp"],
	updated?:PartialObjects["timestamptz_comparison_exp"],
	user?:PartialObjects["users_bool_exp"],
	user_id?:PartialObjects["Int_comparison_exp"]
},
	/** unique or primary key constraints on table "todos" */
["todos_constraint"]:todos_constraint,
	/** input type for incrementing numeric columns in table "todos" */
["todos_inc_input"]: {
	current_count?:number,
	goal_id?:number,
	id?:number,
	user_id?:number
},
	/** input type for inserting data into table "todos" */
["todos_insert_input"]: {
	current_count?:number,
	done_as_expected?:boolean,
	due?:PartialObjects["timestamptz"],
	goal?:PartialObjects["goals_obj_rel_insert_input"],
	goal_id?:number,
	id?:number,
	name?:string,
	status?:string,
	updated?:PartialObjects["timestamptz"],
	user?:PartialObjects["users_obj_rel_insert_input"],
	user_id?:number
},
	/** aggregate max on columns */
["todos_max_fields"]: {
		__typename?: "todos_max_fields";
			current_count?:number,
			due?:PartialObjects["timestamptz"],
			goal_id?:number,
			id?:number,
			name?:string,
			status?:string,
			updated?:PartialObjects["timestamptz"],
			user_id?:number
	},
	/** aggregate min on columns */
["todos_min_fields"]: {
		__typename?: "todos_min_fields";
			current_count?:number,
			due?:PartialObjects["timestamptz"],
			goal_id?:number,
			id?:number,
			name?:string,
			status?:string,
			updated?:PartialObjects["timestamptz"],
			user_id?:number
	},
	/** response of any mutation on the table "todos" */
["todos_mutation_response"]: {
		__typename?: "todos_mutation_response";
			/** number of rows affected by the mutation */
	affected_rows?:number,
			/** data from the rows affected by the mutation */
	returning?:PartialObjects["todos"][]
	},
	/** input type for inserting object relation for remote table "todos" */
["todos_obj_rel_insert_input"]: {
	data:PartialObjects["todos_insert_input"],
	/** upsert condition */
	on_conflict?:PartialObjects["todos_on_conflict"]
},
	/** on_conflict condition type for table "todos" */
["todos_on_conflict"]: {
	constraint:PartialObjects["todos_constraint"],
	update_columns:PartialObjects["todos_update_column"][],
	where?:PartialObjects["todos_bool_exp"]
},
	/** Ordering options when selecting data from "todos". */
["todos_order_by"]: {
	current_count?:PartialObjects["order_by"],
	done_as_expected?:PartialObjects["order_by"],
	due?:PartialObjects["order_by"],
	goal?:PartialObjects["goals_order_by"],
	goal_id?:PartialObjects["order_by"],
	id?:PartialObjects["order_by"],
	name?:PartialObjects["order_by"],
	status?:PartialObjects["order_by"],
	updated?:PartialObjects["order_by"],
	user?:PartialObjects["users_order_by"],
	user_id?:PartialObjects["order_by"]
},
	/** primary key columns input for table: todos */
["todos_pk_columns_input"]: {
	id:number
},
	/** select columns of table "todos" */
["todos_select_column"]:todos_select_column,
	/** input type for updating data in table "todos" */
["todos_set_input"]: {
	current_count?:number,
	done_as_expected?:boolean,
	due?:PartialObjects["timestamptz"],
	goal_id?:number,
	id?:number,
	name?:string,
	status?:string,
	updated?:PartialObjects["timestamptz"],
	user_id?:number
},
	/** aggregate stddev on columns */
["todos_stddev_fields"]: {
		__typename?: "todos_stddev_fields";
			current_count?:number,
			goal_id?:number,
			id?:number,
			user_id?:number
	},
	/** aggregate stddev_pop on columns */
["todos_stddev_pop_fields"]: {
		__typename?: "todos_stddev_pop_fields";
			current_count?:number,
			goal_id?:number,
			id?:number,
			user_id?:number
	},
	/** aggregate stddev_samp on columns */
["todos_stddev_samp_fields"]: {
		__typename?: "todos_stddev_samp_fields";
			current_count?:number,
			goal_id?:number,
			id?:number,
			user_id?:number
	},
	/** Streaming cursor of the table "todos" */
["todos_stream_cursor_input"]: {
	/** Stream column input with initial value */
	initial_value:PartialObjects["todos_stream_cursor_value_input"],
	/** cursor ordering */
	ordering?:PartialObjects["cursor_ordering"]
},
	/** Initial value of the column from where the streaming should start */
["todos_stream_cursor_value_input"]: {
	current_count?:number,
	done_as_expected?:boolean,
	due?:PartialObjects["timestamptz"],
	goal_id?:number,
	id?:number,
	name?:string,
	status?:string,
	updated?:PartialObjects["timestamptz"],
	user_id?:number
},
	/** aggregate sum on columns */
["todos_sum_fields"]: {
		__typename?: "todos_sum_fields";
			current_count?:number,
			goal_id?:number,
			id?:number,
			user_id?:number
	},
	/** update columns of table "todos" */
["todos_update_column"]:todos_update_column,
	["todos_updates"]: {
	/** increments the numeric columns with given value of the filtered values */
	_inc?:PartialObjects["todos_inc_input"],
	/** sets the columns of the filtered rows to the given values */
	_set?:PartialObjects["todos_set_input"],
	/** filter the rows which have to be updated */
	where:PartialObjects["todos_bool_exp"]
},
	/** aggregate var_pop on columns */
["todos_var_pop_fields"]: {
		__typename?: "todos_var_pop_fields";
			current_count?:number,
			goal_id?:number,
			id?:number,
			user_id?:number
	},
	/** aggregate var_samp on columns */
["todos_var_samp_fields"]: {
		__typename?: "todos_var_samp_fields";
			current_count?:number,
			goal_id?:number,
			id?:number,
			user_id?:number
	},
	/** aggregate variance on columns */
["todos_variance_fields"]: {
		__typename?: "todos_variance_fields";
			current_count?:number,
			goal_id?:number,
			id?:number,
			user_id?:number
	},
	/** columns and relationships of "users" */
["users"]: {
		__typename?: "users";
			apple_id?:string,
			/** A computed field, executes function "closest_user_location" */
	closest_user_location?:PartialObjects["locations"][],
			config?:PartialObjects["jsonb"],
			/** An array relationship */
	events?:PartialObjects["events"][],
			/** An aggregate relationship */
	events_aggregate?:PartialObjects["events_aggregate"],
			id?:number,
			language?:string,
			/** An array relationship */
	locations?:PartialObjects["locations"][],
			/** An aggregate relationship */
	locations_aggregate?:PartialObjects["locations_aggregate"],
			name?:string,
			timezone?:string
	},
	/** aggregated selection of "users" */
["users_aggregate"]: {
		__typename?: "users_aggregate";
			aggregate?:PartialObjects["users_aggregate_fields"],
			nodes?:PartialObjects["users"][]
	},
	/** aggregate fields of "users" */
["users_aggregate_fields"]: {
		__typename?: "users_aggregate_fields";
			avg?:PartialObjects["users_avg_fields"],
			count?:number,
			max?:PartialObjects["users_max_fields"],
			min?:PartialObjects["users_min_fields"],
			stddev?:PartialObjects["users_stddev_fields"],
			stddev_pop?:PartialObjects["users_stddev_pop_fields"],
			stddev_samp?:PartialObjects["users_stddev_samp_fields"],
			sum?:PartialObjects["users_sum_fields"],
			var_pop?:PartialObjects["users_var_pop_fields"],
			var_samp?:PartialObjects["users_var_samp_fields"],
			variance?:PartialObjects["users_variance_fields"]
	},
	/** append existing jsonb value of filtered columns with new jsonb value */
["users_append_input"]: {
	config?:PartialObjects["jsonb"]
},
	/** aggregate avg on columns */
["users_avg_fields"]: {
		__typename?: "users_avg_fields";
			id?:number
	},
	/** Boolean expression to filter rows from the table "users". All fields are combined with a logical 'AND'. */
["users_bool_exp"]: {
	_and?:PartialObjects["users_bool_exp"][],
	_not?:PartialObjects["users_bool_exp"],
	_or?:PartialObjects["users_bool_exp"][],
	apple_id?:PartialObjects["String_comparison_exp"],
	config?:PartialObjects["jsonb_comparison_exp"],
	events?:PartialObjects["events_bool_exp"],
	events_aggregate?:PartialObjects["events_aggregate_bool_exp"],
	id?:PartialObjects["Int_comparison_exp"],
	language?:PartialObjects["String_comparison_exp"],
	locations?:PartialObjects["locations_bool_exp"],
	locations_aggregate?:PartialObjects["locations_aggregate_bool_exp"],
	name?:PartialObjects["String_comparison_exp"],
	timezone?:PartialObjects["String_comparison_exp"]
},
	/** unique or primary key constraints on table "users" */
["users_constraint"]:users_constraint,
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
["users_delete_at_path_input"]: {
	config?:string[]
},
	/** delete the array element with specified index (negative integers count from the
end). throws an error if top level container is not an array */
["users_delete_elem_input"]: {
	config?:number
},
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
["users_delete_key_input"]: {
	config?:string
},
	/** input type for incrementing numeric columns in table "users" */
["users_inc_input"]: {
	id?:number
},
	/** input type for inserting data into table "users" */
["users_insert_input"]: {
	apple_id?:string,
	config?:PartialObjects["jsonb"],
	events?:PartialObjects["events_arr_rel_insert_input"],
	id?:number,
	language?:string,
	locations?:PartialObjects["locations_arr_rel_insert_input"],
	name?:string,
	timezone?:string
},
	/** aggregate max on columns */
["users_max_fields"]: {
		__typename?: "users_max_fields";
			apple_id?:string,
			id?:number,
			language?:string,
			name?:string,
			timezone?:string
	},
	/** aggregate min on columns */
["users_min_fields"]: {
		__typename?: "users_min_fields";
			apple_id?:string,
			id?:number,
			language?:string,
			name?:string,
			timezone?:string
	},
	/** response of any mutation on the table "users" */
["users_mutation_response"]: {
		__typename?: "users_mutation_response";
			/** number of rows affected by the mutation */
	affected_rows?:number,
			/** data from the rows affected by the mutation */
	returning?:PartialObjects["users"][]
	},
	/** input type for inserting object relation for remote table "users" */
["users_obj_rel_insert_input"]: {
	data:PartialObjects["users_insert_input"],
	/** upsert condition */
	on_conflict?:PartialObjects["users_on_conflict"]
},
	/** on_conflict condition type for table "users" */
["users_on_conflict"]: {
	constraint:PartialObjects["users_constraint"],
	update_columns:PartialObjects["users_update_column"][],
	where?:PartialObjects["users_bool_exp"]
},
	/** Ordering options when selecting data from "users". */
["users_order_by"]: {
	apple_id?:PartialObjects["order_by"],
	config?:PartialObjects["order_by"],
	events_aggregate?:PartialObjects["events_aggregate_order_by"],
	id?:PartialObjects["order_by"],
	language?:PartialObjects["order_by"],
	locations_aggregate?:PartialObjects["locations_aggregate_order_by"],
	name?:PartialObjects["order_by"],
	timezone?:PartialObjects["order_by"]
},
	/** primary key columns input for table: users */
["users_pk_columns_input"]: {
	id:number
},
	/** prepend existing jsonb value of filtered columns with new jsonb value */
["users_prepend_input"]: {
	config?:PartialObjects["jsonb"]
},
	["users_scalar"]:any,
	/** select columns of table "users" */
["users_select_column"]:users_select_column,
	/** input type for updating data in table "users" */
["users_set_input"]: {
	apple_id?:string,
	config?:PartialObjects["jsonb"],
	id?:number,
	language?:string,
	name?:string,
	timezone?:string
},
	/** aggregate stddev on columns */
["users_stddev_fields"]: {
		__typename?: "users_stddev_fields";
			id?:number
	},
	/** aggregate stddev_pop on columns */
["users_stddev_pop_fields"]: {
		__typename?: "users_stddev_pop_fields";
			id?:number
	},
	/** aggregate stddev_samp on columns */
["users_stddev_samp_fields"]: {
		__typename?: "users_stddev_samp_fields";
			id?:number
	},
	/** Streaming cursor of the table "users" */
["users_stream_cursor_input"]: {
	/** Stream column input with initial value */
	initial_value:PartialObjects["users_stream_cursor_value_input"],
	/** cursor ordering */
	ordering?:PartialObjects["cursor_ordering"]
},
	/** Initial value of the column from where the streaming should start */
["users_stream_cursor_value_input"]: {
	apple_id?:string,
	config?:PartialObjects["jsonb"],
	id?:number,
	language?:string,
	name?:string,
	timezone?:string
},
	/** aggregate sum on columns */
["users_sum_fields"]: {
		__typename?: "users_sum_fields";
			id?:number
	},
	/** update columns of table "users" */
["users_update_column"]:users_update_column,
	["users_updates"]: {
	/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:PartialObjects["users_append_input"],
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:PartialObjects["users_delete_at_path_input"],
	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:PartialObjects["users_delete_elem_input"],
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:PartialObjects["users_delete_key_input"],
	/** increments the numeric columns with given value of the filtered values */
	_inc?:PartialObjects["users_inc_input"],
	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:PartialObjects["users_prepend_input"],
	/** sets the columns of the filtered rows to the given values */
	_set?:PartialObjects["users_set_input"],
	/** filter the rows which have to be updated */
	where:PartialObjects["users_bool_exp"]
},
	/** aggregate var_pop on columns */
["users_var_pop_fields"]: {
		__typename?: "users_var_pop_fields";
			id?:number
	},
	/** aggregate var_samp on columns */
["users_var_samp_fields"]: {
		__typename?: "users_var_samp_fields";
			id?:number
	},
	/** aggregate variance on columns */
["users_variance_fields"]: {
		__typename?: "users_variance_fields";
			id?:number
	},
	["vector"]:any,
	/** Boolean expression to compare columns of type "vector". All fields are combined with logical 'AND'. */
["vector_comparison_exp"]: {
	_eq?:PartialObjects["vector"],
	_gt?:PartialObjects["vector"],
	_gte?:PartialObjects["vector"],
	_in?:PartialObjects["vector"][],
	_is_null?:boolean,
	_lt?:PartialObjects["vector"],
	_lte?:PartialObjects["vector"],
	_neq?:PartialObjects["vector"],
	_nin?:PartialObjects["vector"][]
}
  }



/** columns and relationships of "associations" */
export type associations = {
	__typename?: "associations",
	id:number,
	metadata:jsonb,
	ref_one_id:number,
	ref_one_table:string,
	ref_two_id:number,
	ref_two_table:string
}

/** aggregated selection of "associations" */
export type associations_aggregate = {
	__typename?: "associations_aggregate",
	aggregate?:associations_aggregate_fields,
	nodes:associations[]
}

/** aggregate fields of "associations" */
export type associations_aggregate_fields = {
	__typename?: "associations_aggregate_fields",
	avg?:associations_avg_fields,
	count:number,
	max?:associations_max_fields,
	min?:associations_min_fields,
	stddev?:associations_stddev_fields,
	stddev_pop?:associations_stddev_pop_fields,
	stddev_samp?:associations_stddev_samp_fields,
	sum?:associations_sum_fields,
	var_pop?:associations_var_pop_fields,
	var_samp?:associations_var_samp_fields,
	variance?:associations_variance_fields
}

/** order by aggregate values of table "associations" */
export type associations_aggregate_order_by = {
		avg?:associations_avg_order_by,
	count?:order_by,
	max?:associations_max_order_by,
	min?:associations_min_order_by,
	stddev?:associations_stddev_order_by,
	stddev_pop?:associations_stddev_pop_order_by,
	stddev_samp?:associations_stddev_samp_order_by,
	sum?:associations_sum_order_by,
	var_pop?:associations_var_pop_order_by,
	var_samp?:associations_var_samp_order_by,
	variance?:associations_variance_order_by
}

/** append existing jsonb value of filtered columns with new jsonb value */
export type associations_append_input = {
		metadata?:jsonb
}

/** aggregate avg on columns */
export type associations_avg_fields = {
	__typename?: "associations_avg_fields",
	id?:number,
	ref_one_id?:number,
	ref_two_id?:number
}

/** order by avg() on columns of table "associations" */
export type associations_avg_order_by = {
		id?:order_by,
	ref_one_id?:order_by,
	ref_two_id?:order_by
}

/** Boolean expression to filter rows from the table "associations". All fields are combined with a logical 'AND'. */
export type associations_bool_exp = {
		_and?:associations_bool_exp[],
	_not?:associations_bool_exp,
	_or?:associations_bool_exp[],
	id?:Int_comparison_exp,
	metadata?:jsonb_comparison_exp,
	ref_one_id?:Int_comparison_exp,
	ref_one_table?:String_comparison_exp,
	ref_two_id?:Int_comparison_exp,
	ref_two_table?:String_comparison_exp
}

/** unique or primary key constraints on table "associations" */
export enum associations_constraint {
	associations_pkey = "associations_pkey"
}

/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
export type associations_delete_at_path_input = {
		metadata?:string[]
}

/** delete the array element with specified index (negative integers count from the
end). throws an error if top level container is not an array */
export type associations_delete_elem_input = {
		metadata?:number
}

/** delete key/value pair or string element. key/value pairs are matched based on their key value */
export type associations_delete_key_input = {
		metadata?:string
}

/** input type for incrementing numeric columns in table "associations" */
export type associations_inc_input = {
		id?:number,
	ref_one_id?:number,
	ref_two_id?:number
}

/** input type for inserting data into table "associations" */
export type associations_insert_input = {
		id?:number,
	metadata?:jsonb,
	ref_one_id?:number,
	ref_one_table?:string,
	ref_two_id?:number,
	ref_two_table?:string
}

/** aggregate max on columns */
export type associations_max_fields = {
	__typename?: "associations_max_fields",
	id?:number,
	ref_one_id?:number,
	ref_one_table?:string,
	ref_two_id?:number,
	ref_two_table?:string
}

/** order by max() on columns of table "associations" */
export type associations_max_order_by = {
		id?:order_by,
	ref_one_id?:order_by,
	ref_one_table?:order_by,
	ref_two_id?:order_by,
	ref_two_table?:order_by
}

/** aggregate min on columns */
export type associations_min_fields = {
	__typename?: "associations_min_fields",
	id?:number,
	ref_one_id?:number,
	ref_one_table?:string,
	ref_two_id?:number,
	ref_two_table?:string
}

/** order by min() on columns of table "associations" */
export type associations_min_order_by = {
		id?:order_by,
	ref_one_id?:order_by,
	ref_one_table?:order_by,
	ref_two_id?:order_by,
	ref_two_table?:order_by
}

/** response of any mutation on the table "associations" */
export type associations_mutation_response = {
	__typename?: "associations_mutation_response",
	/** number of rows affected by the mutation */
	affected_rows:number,
	/** data from the rows affected by the mutation */
	returning:associations[]
}

/** on_conflict condition type for table "associations" */
export type associations_on_conflict = {
		constraint:associations_constraint,
	update_columns:associations_update_column[],
	where?:associations_bool_exp
}

/** Ordering options when selecting data from "associations". */
export type associations_order_by = {
		id?:order_by,
	metadata?:order_by,
	ref_one_id?:order_by,
	ref_one_table?:order_by,
	ref_two_id?:order_by,
	ref_two_table?:order_by
}

/** primary key columns input for table: associations */
export type associations_pk_columns_input = {
		id:number
}

/** prepend existing jsonb value of filtered columns with new jsonb value */
export type associations_prepend_input = {
		metadata?:jsonb
}

/** select columns of table "associations" */
export enum associations_select_column {
	id = "id",
	metadata = "metadata",
	ref_one_id = "ref_one_id",
	ref_one_table = "ref_one_table",
	ref_two_id = "ref_two_id",
	ref_two_table = "ref_two_table"
}

/** input type for updating data in table "associations" */
export type associations_set_input = {
		id?:number,
	metadata?:jsonb,
	ref_one_id?:number,
	ref_one_table?:string,
	ref_two_id?:number,
	ref_two_table?:string
}

/** aggregate stddev on columns */
export type associations_stddev_fields = {
	__typename?: "associations_stddev_fields",
	id?:number,
	ref_one_id?:number,
	ref_two_id?:number
}

/** order by stddev() on columns of table "associations" */
export type associations_stddev_order_by = {
		id?:order_by,
	ref_one_id?:order_by,
	ref_two_id?:order_by
}

/** aggregate stddev_pop on columns */
export type associations_stddev_pop_fields = {
	__typename?: "associations_stddev_pop_fields",
	id?:number,
	ref_one_id?:number,
	ref_two_id?:number
}

/** order by stddev_pop() on columns of table "associations" */
export type associations_stddev_pop_order_by = {
		id?:order_by,
	ref_one_id?:order_by,
	ref_two_id?:order_by
}

/** aggregate stddev_samp on columns */
export type associations_stddev_samp_fields = {
	__typename?: "associations_stddev_samp_fields",
	id?:number,
	ref_one_id?:number,
	ref_two_id?:number
}

/** order by stddev_samp() on columns of table "associations" */
export type associations_stddev_samp_order_by = {
		id?:order_by,
	ref_one_id?:order_by,
	ref_two_id?:order_by
}

/** Streaming cursor of the table "associations" */
export type associations_stream_cursor_input = {
		/** Stream column input with initial value */
	initial_value:associations_stream_cursor_value_input,
	/** cursor ordering */
	ordering?:cursor_ordering
}

/** Initial value of the column from where the streaming should start */
export type associations_stream_cursor_value_input = {
		id?:number,
	metadata?:jsonb,
	ref_one_id?:number,
	ref_one_table?:string,
	ref_two_id?:number,
	ref_two_table?:string
}

/** aggregate sum on columns */
export type associations_sum_fields = {
	__typename?: "associations_sum_fields",
	id?:number,
	ref_one_id?:number,
	ref_two_id?:number
}

/** order by sum() on columns of table "associations" */
export type associations_sum_order_by = {
		id?:order_by,
	ref_one_id?:order_by,
	ref_two_id?:order_by
}

/** update columns of table "associations" */
export enum associations_update_column {
	id = "id",
	metadata = "metadata",
	ref_one_id = "ref_one_id",
	ref_one_table = "ref_one_table",
	ref_two_id = "ref_two_id",
	ref_two_table = "ref_two_table"
}

export type associations_updates = {
		/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:associations_append_input,
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:associations_delete_at_path_input,
	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:associations_delete_elem_input,
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:associations_delete_key_input,
	/** increments the numeric columns with given value of the filtered values */
	_inc?:associations_inc_input,
	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:associations_prepend_input,
	/** sets the columns of the filtered rows to the given values */
	_set?:associations_set_input,
	/** filter the rows which have to be updated */
	where:associations_bool_exp
}

/** aggregate var_pop on columns */
export type associations_var_pop_fields = {
	__typename?: "associations_var_pop_fields",
	id?:number,
	ref_one_id?:number,
	ref_two_id?:number
}

/** order by var_pop() on columns of table "associations" */
export type associations_var_pop_order_by = {
		id?:order_by,
	ref_one_id?:order_by,
	ref_two_id?:order_by
}

/** aggregate var_samp on columns */
export type associations_var_samp_fields = {
	__typename?: "associations_var_samp_fields",
	id?:number,
	ref_one_id?:number,
	ref_two_id?:number
}

/** order by var_samp() on columns of table "associations" */
export type associations_var_samp_order_by = {
		id?:order_by,
	ref_one_id?:order_by,
	ref_two_id?:order_by
}

/** aggregate variance on columns */
export type associations_variance_fields = {
	__typename?: "associations_variance_fields",
	id?:number,
	ref_one_id?:number,
	ref_two_id?:number
}

/** order by variance() on columns of table "associations" */
export type associations_variance_order_by = {
		id?:order_by,
	ref_one_id?:order_by,
	ref_two_id?:order_by
}

/** Boolean expression to compare columns of type "Boolean". All fields are combined with logical 'AND'. */
export type Boolean_comparison_exp = {
		_eq?:boolean,
	_gt?:boolean,
	_gte?:boolean,
	_in?:boolean[],
	_is_null?:boolean,
	_lt?:boolean,
	_lte?:boolean,
	_neq?:boolean,
	_nin?:boolean[]
}

export type closest_user_location_args = {
		radius?:float8,
	ref_point?:string,
	user_row?:users_scalar
}

export type closest_user_location_users_args = {
		radius?:float8,
	ref_point?:string
}

/** ordering argument of a cursor */
export enum cursor_ordering {
	ASC = "ASC",
	DESC = "DESC"
}

/** columns and relationships of "event_tag" */
export type event_tag = {
	__typename?: "event_tag",
	/** An object relationship */
	event:events,
	event_id:number,
	tag_name:string
}

/** aggregated selection of "event_tag" */
export type event_tag_aggregate = {
	__typename?: "event_tag_aggregate",
	aggregate?:event_tag_aggregate_fields,
	nodes:event_tag[]
}

export type event_tag_aggregate_bool_exp = {
		count?:event_tag_aggregate_bool_exp_count
}

export type event_tag_aggregate_bool_exp_count = {
		arguments?:event_tag_select_column[],
	distinct?:boolean,
	filter?:event_tag_bool_exp,
	predicate:Int_comparison_exp
}

/** aggregate fields of "event_tag" */
export type event_tag_aggregate_fields = {
	__typename?: "event_tag_aggregate_fields",
	avg?:event_tag_avg_fields,
	count:number,
	max?:event_tag_max_fields,
	min?:event_tag_min_fields,
	stddev?:event_tag_stddev_fields,
	stddev_pop?:event_tag_stddev_pop_fields,
	stddev_samp?:event_tag_stddev_samp_fields,
	sum?:event_tag_sum_fields,
	var_pop?:event_tag_var_pop_fields,
	var_samp?:event_tag_var_samp_fields,
	variance?:event_tag_variance_fields
}

/** order by aggregate values of table "event_tag" */
export type event_tag_aggregate_order_by = {
		avg?:event_tag_avg_order_by,
	count?:order_by,
	max?:event_tag_max_order_by,
	min?:event_tag_min_order_by,
	stddev?:event_tag_stddev_order_by,
	stddev_pop?:event_tag_stddev_pop_order_by,
	stddev_samp?:event_tag_stddev_samp_order_by,
	sum?:event_tag_sum_order_by,
	var_pop?:event_tag_var_pop_order_by,
	var_samp?:event_tag_var_samp_order_by,
	variance?:event_tag_variance_order_by
}

/** input type for inserting array relation for remote table "event_tag" */
export type event_tag_arr_rel_insert_input = {
		data:event_tag_insert_input[],
	/** upsert condition */
	on_conflict?:event_tag_on_conflict
}

/** aggregate avg on columns */
export type event_tag_avg_fields = {
	__typename?: "event_tag_avg_fields",
	event_id?:number
}

/** order by avg() on columns of table "event_tag" */
export type event_tag_avg_order_by = {
		event_id?:order_by
}

/** Boolean expression to filter rows from the table "event_tag". All fields are combined with a logical 'AND'. */
export type event_tag_bool_exp = {
		_and?:event_tag_bool_exp[],
	_not?:event_tag_bool_exp,
	_or?:event_tag_bool_exp[],
	event?:events_bool_exp,
	event_id?:Int_comparison_exp,
	tag_name?:String_comparison_exp
}

/** unique or primary key constraints on table "event_tag" */
export enum event_tag_constraint {
	event_tag_pkey = "event_tag_pkey"
}

/** input type for incrementing numeric columns in table "event_tag" */
export type event_tag_inc_input = {
		event_id?:number
}

/** input type for inserting data into table "event_tag" */
export type event_tag_insert_input = {
		event?:events_obj_rel_insert_input,
	event_id?:number,
	tag_name?:string
}

/** aggregate max on columns */
export type event_tag_max_fields = {
	__typename?: "event_tag_max_fields",
	event_id?:number,
	tag_name?:string
}

/** order by max() on columns of table "event_tag" */
export type event_tag_max_order_by = {
		event_id?:order_by,
	tag_name?:order_by
}

/** aggregate min on columns */
export type event_tag_min_fields = {
	__typename?: "event_tag_min_fields",
	event_id?:number,
	tag_name?:string
}

/** order by min() on columns of table "event_tag" */
export type event_tag_min_order_by = {
		event_id?:order_by,
	tag_name?:order_by
}

/** response of any mutation on the table "event_tag" */
export type event_tag_mutation_response = {
	__typename?: "event_tag_mutation_response",
	/** number of rows affected by the mutation */
	affected_rows:number,
	/** data from the rows affected by the mutation */
	returning:event_tag[]
}

/** on_conflict condition type for table "event_tag" */
export type event_tag_on_conflict = {
		constraint:event_tag_constraint,
	update_columns:event_tag_update_column[],
	where?:event_tag_bool_exp
}

/** Ordering options when selecting data from "event_tag". */
export type event_tag_order_by = {
		event?:events_order_by,
	event_id?:order_by,
	tag_name?:order_by
}

/** primary key columns input for table: event_tag */
export type event_tag_pk_columns_input = {
		event_id:number,
	tag_name:string
}

/** select columns of table "event_tag" */
export enum event_tag_select_column {
	event_id = "event_id",
	tag_name = "tag_name"
}

/** input type for updating data in table "event_tag" */
export type event_tag_set_input = {
		event_id?:number,
	tag_name?:string
}

/** aggregate stddev on columns */
export type event_tag_stddev_fields = {
	__typename?: "event_tag_stddev_fields",
	event_id?:number
}

/** order by stddev() on columns of table "event_tag" */
export type event_tag_stddev_order_by = {
		event_id?:order_by
}

/** aggregate stddev_pop on columns */
export type event_tag_stddev_pop_fields = {
	__typename?: "event_tag_stddev_pop_fields",
	event_id?:number
}

/** order by stddev_pop() on columns of table "event_tag" */
export type event_tag_stddev_pop_order_by = {
		event_id?:order_by
}

/** aggregate stddev_samp on columns */
export type event_tag_stddev_samp_fields = {
	__typename?: "event_tag_stddev_samp_fields",
	event_id?:number
}

/** order by stddev_samp() on columns of table "event_tag" */
export type event_tag_stddev_samp_order_by = {
		event_id?:order_by
}

/** Streaming cursor of the table "event_tag" */
export type event_tag_stream_cursor_input = {
		/** Stream column input with initial value */
	initial_value:event_tag_stream_cursor_value_input,
	/** cursor ordering */
	ordering?:cursor_ordering
}

/** Initial value of the column from where the streaming should start */
export type event_tag_stream_cursor_value_input = {
		event_id?:number,
	tag_name?:string
}

/** aggregate sum on columns */
export type event_tag_sum_fields = {
	__typename?: "event_tag_sum_fields",
	event_id?:number
}

/** order by sum() on columns of table "event_tag" */
export type event_tag_sum_order_by = {
		event_id?:order_by
}

/** update columns of table "event_tag" */
export enum event_tag_update_column {
	event_id = "event_id",
	tag_name = "tag_name"
}

export type event_tag_updates = {
		/** increments the numeric columns with given value of the filtered values */
	_inc?:event_tag_inc_input,
	/** sets the columns of the filtered rows to the given values */
	_set?:event_tag_set_input,
	/** filter the rows which have to be updated */
	where:event_tag_bool_exp
}

/** aggregate var_pop on columns */
export type event_tag_var_pop_fields = {
	__typename?: "event_tag_var_pop_fields",
	event_id?:number
}

/** order by var_pop() on columns of table "event_tag" */
export type event_tag_var_pop_order_by = {
		event_id?:order_by
}

/** aggregate var_samp on columns */
export type event_tag_var_samp_fields = {
	__typename?: "event_tag_var_samp_fields",
	event_id?:number
}

/** order by var_samp() on columns of table "event_tag" */
export type event_tag_var_samp_order_by = {
		event_id?:order_by
}

/** aggregate variance on columns */
export type event_tag_variance_fields = {
	__typename?: "event_tag_variance_fields",
	event_id?:number
}

/** order by variance() on columns of table "event_tag" */
export type event_tag_variance_order_by = {
		event_id?:order_by
}

/** columns and relationships of "event_types" */
export type event_types = {
	__typename?: "event_types",
	/** An array relationship */
	children:event_types[],
	/** An aggregate relationship */
	children_aggregate:event_types_aggregate,
	embedding?:vector,
	metadata?:jsonb,
	name:string,
	parent?:string,
	/** A computed field, executes function "get_event_type_path" */
	parent_tree?:string
}

/** aggregated selection of "event_types" */
export type event_types_aggregate = {
	__typename?: "event_types_aggregate",
	aggregate?:event_types_aggregate_fields,
	nodes:event_types[]
}

export type event_types_aggregate_bool_exp = {
		count?:event_types_aggregate_bool_exp_count
}

export type event_types_aggregate_bool_exp_count = {
		arguments?:event_types_select_column[],
	distinct?:boolean,
	filter?:event_types_bool_exp,
	predicate:Int_comparison_exp
}

/** aggregate fields of "event_types" */
export type event_types_aggregate_fields = {
	__typename?: "event_types_aggregate_fields",
	count:number,
	max?:event_types_max_fields,
	min?:event_types_min_fields
}

/** order by aggregate values of table "event_types" */
export type event_types_aggregate_order_by = {
		count?:order_by,
	max?:event_types_max_order_by,
	min?:event_types_min_order_by
}

/** append existing jsonb value of filtered columns with new jsonb value */
export type event_types_append_input = {
		metadata?:jsonb
}

/** input type for inserting array relation for remote table "event_types" */
export type event_types_arr_rel_insert_input = {
		data:event_types_insert_input[],
	/** upsert condition */
	on_conflict?:event_types_on_conflict
}

/** Boolean expression to filter rows from the table "event_types". All fields are combined with a logical 'AND'. */
export type event_types_bool_exp = {
		_and?:event_types_bool_exp[],
	_not?:event_types_bool_exp,
	_or?:event_types_bool_exp[],
	children?:event_types_bool_exp,
	children_aggregate?:event_types_aggregate_bool_exp,
	embedding?:vector_comparison_exp,
	metadata?:jsonb_comparison_exp,
	name?:String_comparison_exp,
	parent?:String_comparison_exp,
	parent_tree?:String_comparison_exp
}

/** unique or primary key constraints on table "event_types" */
export enum event_types_constraint {
	tags_name_key = "tags_name_key",
	tags_pkey = "tags_pkey"
}

/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
export type event_types_delete_at_path_input = {
		metadata?:string[]
}

/** delete the array element with specified index (negative integers count from the
end). throws an error if top level container is not an array */
export type event_types_delete_elem_input = {
		metadata?:number
}

/** delete key/value pair or string element. key/value pairs are matched based on their key value */
export type event_types_delete_key_input = {
		metadata?:string
}

/** input type for inserting data into table "event_types" */
export type event_types_insert_input = {
		children?:event_types_arr_rel_insert_input,
	embedding?:vector,
	metadata?:jsonb,
	name?:string,
	parent?:string
}

/** aggregate max on columns */
export type event_types_max_fields = {
	__typename?: "event_types_max_fields",
	name?:string,
	parent?:string,
	/** A computed field, executes function "get_event_type_path" */
	parent_tree?:string
}

/** order by max() on columns of table "event_types" */
export type event_types_max_order_by = {
		name?:order_by,
	parent?:order_by
}

/** aggregate min on columns */
export type event_types_min_fields = {
	__typename?: "event_types_min_fields",
	name?:string,
	parent?:string,
	/** A computed field, executes function "get_event_type_path" */
	parent_tree?:string
}

/** order by min() on columns of table "event_types" */
export type event_types_min_order_by = {
		name?:order_by,
	parent?:order_by
}

/** response of any mutation on the table "event_types" */
export type event_types_mutation_response = {
	__typename?: "event_types_mutation_response",
	/** number of rows affected by the mutation */
	affected_rows:number,
	/** data from the rows affected by the mutation */
	returning:event_types[]
}

/** input type for inserting object relation for remote table "event_types" */
export type event_types_obj_rel_insert_input = {
		data:event_types_insert_input,
	/** upsert condition */
	on_conflict?:event_types_on_conflict
}

/** on_conflict condition type for table "event_types" */
export type event_types_on_conflict = {
		constraint:event_types_constraint,
	update_columns:event_types_update_column[],
	where?:event_types_bool_exp
}

/** Ordering options when selecting data from "event_types". */
export type event_types_order_by = {
		children_aggregate?:event_types_aggregate_order_by,
	embedding?:order_by,
	metadata?:order_by,
	name?:order_by,
	parent?:order_by,
	parent_tree?:order_by
}

/** primary key columns input for table: event_types */
export type event_types_pk_columns_input = {
		name:string
}

/** prepend existing jsonb value of filtered columns with new jsonb value */
export type event_types_prepend_input = {
		metadata?:jsonb
}

/** select columns of table "event_types" */
export enum event_types_select_column {
	embedding = "embedding",
	metadata = "metadata",
	name = "name",
	parent = "parent"
}

/** input type for updating data in table "event_types" */
export type event_types_set_input = {
		embedding?:vector,
	metadata?:jsonb,
	name?:string,
	parent?:string
}

/** Streaming cursor of the table "event_types" */
export type event_types_stream_cursor_input = {
		/** Stream column input with initial value */
	initial_value:event_types_stream_cursor_value_input,
	/** cursor ordering */
	ordering?:cursor_ordering
}

/** Initial value of the column from where the streaming should start */
export type event_types_stream_cursor_value_input = {
		embedding?:vector,
	metadata?:jsonb,
	name?:string,
	parent?:string
}

/** update columns of table "event_types" */
export enum event_types_update_column {
	embedding = "embedding",
	metadata = "metadata",
	name = "name",
	parent = "parent"
}

export type event_types_updates = {
		/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:event_types_append_input,
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:event_types_delete_at_path_input,
	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:event_types_delete_elem_input,
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:event_types_delete_key_input,
	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:event_types_prepend_input,
	/** sets the columns of the filtered rows to the given values */
	_set?:event_types_set_input,
	/** filter the rows which have to be updated */
	where:event_types_bool_exp
}

/** columns and relationships of "events" */
export type events = {
	__typename?: "events",
	/** A computed field, executes function "event_associations" */
	associations?:associations[],
	/** An array relationship */
	children:events[],
	/** An aggregate relationship */
	children_aggregate:events_aggregate,
	/** A computed field, executes function "event_duration" */
	computed_cost_time?:number,
	/** cents */
	cost_money?:number,
	/** seconds */
	cost_time?:number,
	end_time?:timestamp,
	/** An array relationship */
	event_tags:event_tag[],
	/** An aggregate relationship */
	event_tags_aggregate:event_tag_aggregate,
	event_type:string,
	/** An object relationship */
	event_type_object:event_types,
	goal_id?:number,
	id:number,
	/** An object relationship */
	interaction?:interactions,
	interaction_id?:number,
	logs?:jsonb,
	metadata?:jsonb,
	/** An object relationship */
	parent?:events,
	parent_id?:number,
	start_time?:timestamp,
	status?:string,
	/** An object relationship */
	user:users,
	user_id:number
}

/** aggregated selection of "events" */
export type events_aggregate = {
	__typename?: "events_aggregate",
	aggregate?:events_aggregate_fields,
	nodes:events[]
}

export type events_aggregate_bool_exp = {
		count?:events_aggregate_bool_exp_count
}

export type events_aggregate_bool_exp_count = {
		arguments?:events_select_column[],
	distinct?:boolean,
	filter?:events_bool_exp,
	predicate:Int_comparison_exp
}

/** aggregate fields of "events" */
export type events_aggregate_fields = {
	__typename?: "events_aggregate_fields",
	avg?:events_avg_fields,
	count:number,
	max?:events_max_fields,
	min?:events_min_fields,
	stddev?:events_stddev_fields,
	stddev_pop?:events_stddev_pop_fields,
	stddev_samp?:events_stddev_samp_fields,
	sum?:events_sum_fields,
	var_pop?:events_var_pop_fields,
	var_samp?:events_var_samp_fields,
	variance?:events_variance_fields
}

/** order by aggregate values of table "events" */
export type events_aggregate_order_by = {
		avg?:events_avg_order_by,
	count?:order_by,
	max?:events_max_order_by,
	min?:events_min_order_by,
	stddev?:events_stddev_order_by,
	stddev_pop?:events_stddev_pop_order_by,
	stddev_samp?:events_stddev_samp_order_by,
	sum?:events_sum_order_by,
	var_pop?:events_var_pop_order_by,
	var_samp?:events_var_samp_order_by,
	variance?:events_variance_order_by
}

/** append existing jsonb value of filtered columns with new jsonb value */
export type events_append_input = {
		logs?:jsonb,
	metadata?:jsonb
}

/** input type for inserting array relation for remote table "events" */
export type events_arr_rel_insert_input = {
		data:events_insert_input[],
	/** upsert condition */
	on_conflict?:events_on_conflict
}

/** aggregate avg on columns */
export type events_avg_fields = {
	__typename?: "events_avg_fields",
	/** A computed field, executes function "event_duration" */
	computed_cost_time?:number,
	/** cents */
	cost_money?:number,
	/** seconds */
	cost_time?:number,
	goal_id?:number,
	id?:number,
	interaction_id?:number,
	parent_id?:number,
	user_id?:number
}

/** order by avg() on columns of table "events" */
export type events_avg_order_by = {
		/** cents */
	cost_money?:order_by,
	/** seconds */
	cost_time?:order_by,
	goal_id?:order_by,
	id?:order_by,
	interaction_id?:order_by,
	parent_id?:order_by,
	user_id?:order_by
}

/** Boolean expression to filter rows from the table "events". All fields are combined with a logical 'AND'. */
export type events_bool_exp = {
		_and?:events_bool_exp[],
	_not?:events_bool_exp,
	_or?:events_bool_exp[],
	associations?:associations_bool_exp,
	children?:events_bool_exp,
	children_aggregate?:events_aggregate_bool_exp,
	computed_cost_time?:Int_comparison_exp,
	cost_money?:Int_comparison_exp,
	cost_time?:Int_comparison_exp,
	end_time?:timestamp_comparison_exp,
	event_tags?:event_tag_bool_exp,
	event_tags_aggregate?:event_tag_aggregate_bool_exp,
	event_type?:String_comparison_exp,
	event_type_object?:event_types_bool_exp,
	goal_id?:Int_comparison_exp,
	id?:Int_comparison_exp,
	interaction?:interactions_bool_exp,
	interaction_id?:Int_comparison_exp,
	logs?:jsonb_comparison_exp,
	metadata?:jsonb_comparison_exp,
	parent?:events_bool_exp,
	parent_id?:Int_comparison_exp,
	start_time?:timestamp_comparison_exp,
	status?:String_comparison_exp,
	user?:users_bool_exp,
	user_id?:Int_comparison_exp
}

/** unique or primary key constraints on table "events" */
export enum events_constraint {
	events_pkey = "events_pkey"
}

/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
export type events_delete_at_path_input = {
		logs?:string[],
	metadata?:string[]
}

/** delete the array element with specified index (negative integers count from the
end). throws an error if top level container is not an array */
export type events_delete_elem_input = {
		logs?:number,
	metadata?:number
}

/** delete key/value pair or string element. key/value pairs are matched based on their key value */
export type events_delete_key_input = {
		logs?:string,
	metadata?:string
}

/** input type for incrementing numeric columns in table "events" */
export type events_inc_input = {
		/** cents */
	cost_money?:number,
	/** seconds */
	cost_time?:number,
	goal_id?:number,
	id?:number,
	interaction_id?:number,
	parent_id?:number,
	user_id?:number
}

/** input type for inserting data into table "events" */
export type events_insert_input = {
		children?:events_arr_rel_insert_input,
	/** cents */
	cost_money?:number,
	/** seconds */
	cost_time?:number,
	end_time?:timestamp,
	event_tags?:event_tag_arr_rel_insert_input,
	event_type?:string,
	event_type_object?:event_types_obj_rel_insert_input,
	goal_id?:number,
	id?:number,
	interaction?:interactions_obj_rel_insert_input,
	interaction_id?:number,
	logs?:jsonb,
	metadata?:jsonb,
	parent?:events_obj_rel_insert_input,
	parent_id?:number,
	start_time?:timestamp,
	status?:string,
	user?:users_obj_rel_insert_input,
	user_id?:number
}

/** aggregate max on columns */
export type events_max_fields = {
	__typename?: "events_max_fields",
	/** A computed field, executes function "event_duration" */
	computed_cost_time?:number,
	/** cents */
	cost_money?:number,
	/** seconds */
	cost_time?:number,
	end_time?:timestamp,
	event_type?:string,
	goal_id?:number,
	id?:number,
	interaction_id?:number,
	parent_id?:number,
	start_time?:timestamp,
	status?:string,
	user_id?:number
}

/** order by max() on columns of table "events" */
export type events_max_order_by = {
		/** cents */
	cost_money?:order_by,
	/** seconds */
	cost_time?:order_by,
	end_time?:order_by,
	event_type?:order_by,
	goal_id?:order_by,
	id?:order_by,
	interaction_id?:order_by,
	parent_id?:order_by,
	start_time?:order_by,
	status?:order_by,
	user_id?:order_by
}

/** aggregate min on columns */
export type events_min_fields = {
	__typename?: "events_min_fields",
	/** A computed field, executes function "event_duration" */
	computed_cost_time?:number,
	/** cents */
	cost_money?:number,
	/** seconds */
	cost_time?:number,
	end_time?:timestamp,
	event_type?:string,
	goal_id?:number,
	id?:number,
	interaction_id?:number,
	parent_id?:number,
	start_time?:timestamp,
	status?:string,
	user_id?:number
}

/** order by min() on columns of table "events" */
export type events_min_order_by = {
		/** cents */
	cost_money?:order_by,
	/** seconds */
	cost_time?:order_by,
	end_time?:order_by,
	event_type?:order_by,
	goal_id?:order_by,
	id?:order_by,
	interaction_id?:order_by,
	parent_id?:order_by,
	start_time?:order_by,
	status?:order_by,
	user_id?:order_by
}

/** response of any mutation on the table "events" */
export type events_mutation_response = {
	__typename?: "events_mutation_response",
	/** number of rows affected by the mutation */
	affected_rows:number,
	/** data from the rows affected by the mutation */
	returning:events[]
}

/** input type for inserting object relation for remote table "events" */
export type events_obj_rel_insert_input = {
		data:events_insert_input,
	/** upsert condition */
	on_conflict?:events_on_conflict
}

/** on_conflict condition type for table "events" */
export type events_on_conflict = {
		constraint:events_constraint,
	update_columns:events_update_column[],
	where?:events_bool_exp
}

/** Ordering options when selecting data from "events". */
export type events_order_by = {
		associations_aggregate?:associations_aggregate_order_by,
	children_aggregate?:events_aggregate_order_by,
	computed_cost_time?:order_by,
	cost_money?:order_by,
	cost_time?:order_by,
	end_time?:order_by,
	event_tags_aggregate?:event_tag_aggregate_order_by,
	event_type?:order_by,
	event_type_object?:event_types_order_by,
	goal_id?:order_by,
	id?:order_by,
	interaction?:interactions_order_by,
	interaction_id?:order_by,
	logs?:order_by,
	metadata?:order_by,
	parent?:events_order_by,
	parent_id?:order_by,
	start_time?:order_by,
	status?:order_by,
	user?:users_order_by,
	user_id?:order_by
}

/** primary key columns input for table: events */
export type events_pk_columns_input = {
		id:number
}

/** prepend existing jsonb value of filtered columns with new jsonb value */
export type events_prepend_input = {
		logs?:jsonb,
	metadata?:jsonb
}

/** select columns of table "events" */
export enum events_select_column {
	cost_money = "cost_money",
	cost_time = "cost_time",
	end_time = "end_time",
	event_type = "event_type",
	goal_id = "goal_id",
	id = "id",
	interaction_id = "interaction_id",
	logs = "logs",
	metadata = "metadata",
	parent_id = "parent_id",
	start_time = "start_time",
	status = "status",
	user_id = "user_id"
}

/** input type for updating data in table "events" */
export type events_set_input = {
		/** cents */
	cost_money?:number,
	/** seconds */
	cost_time?:number,
	end_time?:timestamp,
	event_type?:string,
	goal_id?:number,
	id?:number,
	interaction_id?:number,
	logs?:jsonb,
	metadata?:jsonb,
	parent_id?:number,
	start_time?:timestamp,
	status?:string,
	user_id?:number
}

/** aggregate stddev on columns */
export type events_stddev_fields = {
	__typename?: "events_stddev_fields",
	/** A computed field, executes function "event_duration" */
	computed_cost_time?:number,
	/** cents */
	cost_money?:number,
	/** seconds */
	cost_time?:number,
	goal_id?:number,
	id?:number,
	interaction_id?:number,
	parent_id?:number,
	user_id?:number
}

/** order by stddev() on columns of table "events" */
export type events_stddev_order_by = {
		/** cents */
	cost_money?:order_by,
	/** seconds */
	cost_time?:order_by,
	goal_id?:order_by,
	id?:order_by,
	interaction_id?:order_by,
	parent_id?:order_by,
	user_id?:order_by
}

/** aggregate stddev_pop on columns */
export type events_stddev_pop_fields = {
	__typename?: "events_stddev_pop_fields",
	/** A computed field, executes function "event_duration" */
	computed_cost_time?:number,
	/** cents */
	cost_money?:number,
	/** seconds */
	cost_time?:number,
	goal_id?:number,
	id?:number,
	interaction_id?:number,
	parent_id?:number,
	user_id?:number
}

/** order by stddev_pop() on columns of table "events" */
export type events_stddev_pop_order_by = {
		/** cents */
	cost_money?:order_by,
	/** seconds */
	cost_time?:order_by,
	goal_id?:order_by,
	id?:order_by,
	interaction_id?:order_by,
	parent_id?:order_by,
	user_id?:order_by
}

/** aggregate stddev_samp on columns */
export type events_stddev_samp_fields = {
	__typename?: "events_stddev_samp_fields",
	/** A computed field, executes function "event_duration" */
	computed_cost_time?:number,
	/** cents */
	cost_money?:number,
	/** seconds */
	cost_time?:number,
	goal_id?:number,
	id?:number,
	interaction_id?:number,
	parent_id?:number,
	user_id?:number
}

/** order by stddev_samp() on columns of table "events" */
export type events_stddev_samp_order_by = {
		/** cents */
	cost_money?:order_by,
	/** seconds */
	cost_time?:order_by,
	goal_id?:order_by,
	id?:order_by,
	interaction_id?:order_by,
	parent_id?:order_by,
	user_id?:order_by
}

/** Streaming cursor of the table "events" */
export type events_stream_cursor_input = {
		/** Stream column input with initial value */
	initial_value:events_stream_cursor_value_input,
	/** cursor ordering */
	ordering?:cursor_ordering
}

/** Initial value of the column from where the streaming should start */
export type events_stream_cursor_value_input = {
		/** cents */
	cost_money?:number,
	/** seconds */
	cost_time?:number,
	end_time?:timestamp,
	event_type?:string,
	goal_id?:number,
	id?:number,
	interaction_id?:number,
	logs?:jsonb,
	metadata?:jsonb,
	parent_id?:number,
	start_time?:timestamp,
	status?:string,
	user_id?:number
}

/** aggregate sum on columns */
export type events_sum_fields = {
	__typename?: "events_sum_fields",
	/** A computed field, executes function "event_duration" */
	computed_cost_time?:number,
	/** cents */
	cost_money?:number,
	/** seconds */
	cost_time?:number,
	goal_id?:number,
	id?:number,
	interaction_id?:number,
	parent_id?:number,
	user_id?:number
}

/** order by sum() on columns of table "events" */
export type events_sum_order_by = {
		/** cents */
	cost_money?:order_by,
	/** seconds */
	cost_time?:order_by,
	goal_id?:order_by,
	id?:order_by,
	interaction_id?:order_by,
	parent_id?:order_by,
	user_id?:order_by
}

/** update columns of table "events" */
export enum events_update_column {
	cost_money = "cost_money",
	cost_time = "cost_time",
	end_time = "end_time",
	event_type = "event_type",
	goal_id = "goal_id",
	id = "id",
	interaction_id = "interaction_id",
	logs = "logs",
	metadata = "metadata",
	parent_id = "parent_id",
	start_time = "start_time",
	status = "status",
	user_id = "user_id"
}

export type events_updates = {
		/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:events_append_input,
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:events_delete_at_path_input,
	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:events_delete_elem_input,
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:events_delete_key_input,
	/** increments the numeric columns with given value of the filtered values */
	_inc?:events_inc_input,
	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:events_prepend_input,
	/** sets the columns of the filtered rows to the given values */
	_set?:events_set_input,
	/** filter the rows which have to be updated */
	where:events_bool_exp
}

/** aggregate var_pop on columns */
export type events_var_pop_fields = {
	__typename?: "events_var_pop_fields",
	/** A computed field, executes function "event_duration" */
	computed_cost_time?:number,
	/** cents */
	cost_money?:number,
	/** seconds */
	cost_time?:number,
	goal_id?:number,
	id?:number,
	interaction_id?:number,
	parent_id?:number,
	user_id?:number
}

/** order by var_pop() on columns of table "events" */
export type events_var_pop_order_by = {
		/** cents */
	cost_money?:order_by,
	/** seconds */
	cost_time?:order_by,
	goal_id?:order_by,
	id?:order_by,
	interaction_id?:order_by,
	parent_id?:order_by,
	user_id?:order_by
}

/** aggregate var_samp on columns */
export type events_var_samp_fields = {
	__typename?: "events_var_samp_fields",
	/** A computed field, executes function "event_duration" */
	computed_cost_time?:number,
	/** cents */
	cost_money?:number,
	/** seconds */
	cost_time?:number,
	goal_id?:number,
	id?:number,
	interaction_id?:number,
	parent_id?:number,
	user_id?:number
}

/** order by var_samp() on columns of table "events" */
export type events_var_samp_order_by = {
		/** cents */
	cost_money?:order_by,
	/** seconds */
	cost_time?:order_by,
	goal_id?:order_by,
	id?:order_by,
	interaction_id?:order_by,
	parent_id?:order_by,
	user_id?:order_by
}

/** aggregate variance on columns */
export type events_variance_fields = {
	__typename?: "events_variance_fields",
	/** A computed field, executes function "event_duration" */
	computed_cost_time?:number,
	/** cents */
	cost_money?:number,
	/** seconds */
	cost_time?:number,
	goal_id?:number,
	id?:number,
	interaction_id?:number,
	parent_id?:number,
	user_id?:number
}

/** order by variance() on columns of table "events" */
export type events_variance_order_by = {
		/** cents */
	cost_money?:order_by,
	/** seconds */
	cost_time?:order_by,
	goal_id?:order_by,
	id?:order_by,
	interaction_id?:order_by,
	parent_id?:order_by,
	user_id?:order_by
}

export type fetch_associations_args = {
		from_row_id?:number,
	from_row_type?:string
}

export type float8 = any

/** Boolean expression to compare columns of type "float8". All fields are combined with logical 'AND'. */
export type float8_comparison_exp = {
		_eq?:float8,
	_gt?:float8,
	_gte?:float8,
	_in?:float8[],
	_is_null?:boolean,
	_lt?:float8,
	_lte?:float8,
	_neq?:float8,
	_nin?:float8[]
}

export type geography = any

export type geography_cast_exp = {
		geometry?:geometry_comparison_exp
}

/** Boolean expression to compare columns of type "geography". All fields are combined with logical 'AND'. */
export type geography_comparison_exp = {
		_cast?:geography_cast_exp,
	_eq?:geography,
	_gt?:geography,
	_gte?:geography,
	_in?:geography[],
	_is_null?:boolean,
	_lt?:geography,
	_lte?:geography,
	_neq?:geography,
	_nin?:geography[],
	/** is the column within a given distance from the given geography value */
	_st_d_within?:st_d_within_geography_input,
	/** does the column spatially intersect the given geography value */
	_st_intersects?:geography
}

export type geometry = any

export type geometry_cast_exp = {
		geography?:geography_comparison_exp
}

/** Boolean expression to compare columns of type "geometry". All fields are combined with logical 'AND'. */
export type geometry_comparison_exp = {
		_cast?:geometry_cast_exp,
	_eq?:geometry,
	_gt?:geometry,
	_gte?:geometry,
	_in?:geometry[],
	_is_null?:boolean,
	_lt?:geometry,
	_lte?:geometry,
	_neq?:geometry,
	_nin?:geometry[],
	/** is the column within a given 3D distance from the given geometry value */
	_st_3d_d_within?:st_d_within_input,
	/** does the column spatially intersect the given geometry value in 3D */
	_st_3d_intersects?:geometry,
	/** does the column contain the given geometry value */
	_st_contains?:geometry,
	/** does the column cross the given geometry value */
	_st_crosses?:geometry,
	/** is the column within a given distance from the given geometry value */
	_st_d_within?:st_d_within_input,
	/** is the column equal to given geometry value (directionality is ignored) */
	_st_equals?:geometry,
	/** does the column spatially intersect the given geometry value */
	_st_intersects?:geometry,
	/** does the column 'spatially overlap' (intersect but not completely contain) the given geometry value */
	_st_overlaps?:geometry,
	/** does the column have atleast one point in common with the given geometry value */
	_st_touches?:geometry,
	/** is the column contained in the given geometry value */
	_st_within?:geometry
}

/** columns and relationships of "goals" */
export type goals = {
	__typename?: "goals",
	created:timestamptz,
	frequency?:jsonb,
	id:number,
	name:string,
	nl_description:string,
	status:string,
	/** An object relationship */
	todo?:todos,
	/** An object relationship */
	user:users,
	user_id:number
}

/** aggregated selection of "goals" */
export type goals_aggregate = {
	__typename?: "goals_aggregate",
	aggregate?:goals_aggregate_fields,
	nodes:goals[]
}

/** aggregate fields of "goals" */
export type goals_aggregate_fields = {
	__typename?: "goals_aggregate_fields",
	avg?:goals_avg_fields,
	count:number,
	max?:goals_max_fields,
	min?:goals_min_fields,
	stddev?:goals_stddev_fields,
	stddev_pop?:goals_stddev_pop_fields,
	stddev_samp?:goals_stddev_samp_fields,
	sum?:goals_sum_fields,
	var_pop?:goals_var_pop_fields,
	var_samp?:goals_var_samp_fields,
	variance?:goals_variance_fields
}

/** append existing jsonb value of filtered columns with new jsonb value */
export type goals_append_input = {
		frequency?:jsonb
}

/** aggregate avg on columns */
export type goals_avg_fields = {
	__typename?: "goals_avg_fields",
	id?:number,
	user_id?:number
}

/** Boolean expression to filter rows from the table "goals". All fields are combined with a logical 'AND'. */
export type goals_bool_exp = {
		_and?:goals_bool_exp[],
	_not?:goals_bool_exp,
	_or?:goals_bool_exp[],
	created?:timestamptz_comparison_exp,
	frequency?:jsonb_comparison_exp,
	id?:Int_comparison_exp,
	name?:String_comparison_exp,
	nl_description?:String_comparison_exp,
	status?:String_comparison_exp,
	todo?:todos_bool_exp,
	user?:users_bool_exp,
	user_id?:Int_comparison_exp
}

/** unique or primary key constraints on table "goals" */
export enum goals_constraint {
	goal_pkey = "goal_pkey"
}

/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
export type goals_delete_at_path_input = {
		frequency?:string[]
}

/** delete the array element with specified index (negative integers count from the
end). throws an error if top level container is not an array */
export type goals_delete_elem_input = {
		frequency?:number
}

/** delete key/value pair or string element. key/value pairs are matched based on their key value */
export type goals_delete_key_input = {
		frequency?:string
}

/** input type for incrementing numeric columns in table "goals" */
export type goals_inc_input = {
		id?:number,
	user_id?:number
}

/** input type for inserting data into table "goals" */
export type goals_insert_input = {
		created?:timestamptz,
	frequency?:jsonb,
	id?:number,
	name?:string,
	nl_description?:string,
	status?:string,
	todo?:todos_obj_rel_insert_input,
	user?:users_obj_rel_insert_input,
	user_id?:number
}

/** aggregate max on columns */
export type goals_max_fields = {
	__typename?: "goals_max_fields",
	created?:timestamptz,
	id?:number,
	name?:string,
	nl_description?:string,
	status?:string,
	user_id?:number
}

/** aggregate min on columns */
export type goals_min_fields = {
	__typename?: "goals_min_fields",
	created?:timestamptz,
	id?:number,
	name?:string,
	nl_description?:string,
	status?:string,
	user_id?:number
}

/** response of any mutation on the table "goals" */
export type goals_mutation_response = {
	__typename?: "goals_mutation_response",
	/** number of rows affected by the mutation */
	affected_rows:number,
	/** data from the rows affected by the mutation */
	returning:goals[]
}

/** input type for inserting object relation for remote table "goals" */
export type goals_obj_rel_insert_input = {
		data:goals_insert_input,
	/** upsert condition */
	on_conflict?:goals_on_conflict
}

/** on_conflict condition type for table "goals" */
export type goals_on_conflict = {
		constraint:goals_constraint,
	update_columns:goals_update_column[],
	where?:goals_bool_exp
}

/** Ordering options when selecting data from "goals". */
export type goals_order_by = {
		created?:order_by,
	frequency?:order_by,
	id?:order_by,
	name?:order_by,
	nl_description?:order_by,
	status?:order_by,
	todo?:todos_order_by,
	user?:users_order_by,
	user_id?:order_by
}

/** primary key columns input for table: goals */
export type goals_pk_columns_input = {
		id:number
}

/** prepend existing jsonb value of filtered columns with new jsonb value */
export type goals_prepend_input = {
		frequency?:jsonb
}

/** select columns of table "goals" */
export enum goals_select_column {
	created = "created",
	frequency = "frequency",
	id = "id",
	name = "name",
	nl_description = "nl_description",
	status = "status",
	user_id = "user_id"
}

/** input type for updating data in table "goals" */
export type goals_set_input = {
		created?:timestamptz,
	frequency?:jsonb,
	id?:number,
	name?:string,
	nl_description?:string,
	status?:string,
	user_id?:number
}

/** aggregate stddev on columns */
export type goals_stddev_fields = {
	__typename?: "goals_stddev_fields",
	id?:number,
	user_id?:number
}

/** aggregate stddev_pop on columns */
export type goals_stddev_pop_fields = {
	__typename?: "goals_stddev_pop_fields",
	id?:number,
	user_id?:number
}

/** aggregate stddev_samp on columns */
export type goals_stddev_samp_fields = {
	__typename?: "goals_stddev_samp_fields",
	id?:number,
	user_id?:number
}

/** Streaming cursor of the table "goals" */
export type goals_stream_cursor_input = {
		/** Stream column input with initial value */
	initial_value:goals_stream_cursor_value_input,
	/** cursor ordering */
	ordering?:cursor_ordering
}

/** Initial value of the column from where the streaming should start */
export type goals_stream_cursor_value_input = {
		created?:timestamptz,
	frequency?:jsonb,
	id?:number,
	name?:string,
	nl_description?:string,
	status?:string,
	user_id?:number
}

/** aggregate sum on columns */
export type goals_sum_fields = {
	__typename?: "goals_sum_fields",
	id?:number,
	user_id?:number
}

/** update columns of table "goals" */
export enum goals_update_column {
	created = "created",
	frequency = "frequency",
	id = "id",
	name = "name",
	nl_description = "nl_description",
	status = "status",
	user_id = "user_id"
}

export type goals_updates = {
		/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:goals_append_input,
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:goals_delete_at_path_input,
	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:goals_delete_elem_input,
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:goals_delete_key_input,
	/** increments the numeric columns with given value of the filtered values */
	_inc?:goals_inc_input,
	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:goals_prepend_input,
	/** sets the columns of the filtered rows to the given values */
	_set?:goals_set_input,
	/** filter the rows which have to be updated */
	where:goals_bool_exp
}

/** aggregate var_pop on columns */
export type goals_var_pop_fields = {
	__typename?: "goals_var_pop_fields",
	id?:number,
	user_id?:number
}

/** aggregate var_samp on columns */
export type goals_var_samp_fields = {
	__typename?: "goals_var_samp_fields",
	id?:number,
	user_id?:number
}

/** aggregate variance on columns */
export type goals_variance_fields = {
	__typename?: "goals_variance_fields",
	id?:number,
	user_id?:number
}

/** Boolean expression to compare columns of type "Int". All fields are combined with logical 'AND'. */
export type Int_comparison_exp = {
		_eq?:number,
	_gt?:number,
	_gte?:number,
	_in?:number[],
	_is_null?:boolean,
	_lt?:number,
	_lte?:number,
	_neq?:number,
	_nin?:number[]
}

/** columns and relationships of "interactions" */
export type interactions = {
	__typename?: "interactions",
	content:string,
	content_type?:string,
	debug?:jsonb,
	embedding:vector,
	/** An array relationship */
	events:events[],
	/** An aggregate relationship */
	events_aggregate:events_aggregate,
	id:number,
	match_score:float8,
	timestamp?:timestamptz,
	user_id:number
}

/** aggregated selection of "interactions" */
export type interactions_aggregate = {
	__typename?: "interactions_aggregate",
	aggregate?:interactions_aggregate_fields,
	nodes:interactions[]
}

/** aggregate fields of "interactions" */
export type interactions_aggregate_fields = {
	__typename?: "interactions_aggregate_fields",
	avg?:interactions_avg_fields,
	count:number,
	max?:interactions_max_fields,
	min?:interactions_min_fields,
	stddev?:interactions_stddev_fields,
	stddev_pop?:interactions_stddev_pop_fields,
	stddev_samp?:interactions_stddev_samp_fields,
	sum?:interactions_sum_fields,
	var_pop?:interactions_var_pop_fields,
	var_samp?:interactions_var_samp_fields,
	variance?:interactions_variance_fields
}

/** append existing jsonb value of filtered columns with new jsonb value */
export type interactions_append_input = {
		debug?:jsonb
}

/** aggregate avg on columns */
export type interactions_avg_fields = {
	__typename?: "interactions_avg_fields",
	id?:number,
	match_score?:number,
	user_id?:number
}

/** Boolean expression to filter rows from the table "interactions". All fields are combined with a logical 'AND'. */
export type interactions_bool_exp = {
		_and?:interactions_bool_exp[],
	_not?:interactions_bool_exp,
	_or?:interactions_bool_exp[],
	content?:String_comparison_exp,
	content_type?:String_comparison_exp,
	debug?:jsonb_comparison_exp,
	embedding?:vector_comparison_exp,
	events?:events_bool_exp,
	events_aggregate?:events_aggregate_bool_exp,
	id?:Int_comparison_exp,
	match_score?:float8_comparison_exp,
	timestamp?:timestamptz_comparison_exp,
	user_id?:Int_comparison_exp
}

/** unique or primary key constraints on table "interactions" */
export enum interactions_constraint {
	interactions_pkey = "interactions_pkey"
}

/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
export type interactions_delete_at_path_input = {
		debug?:string[]
}

/** delete the array element with specified index (negative integers count from the
end). throws an error if top level container is not an array */
export type interactions_delete_elem_input = {
		debug?:number
}

/** delete key/value pair or string element. key/value pairs are matched based on their key value */
export type interactions_delete_key_input = {
		debug?:string
}

/** input type for incrementing numeric columns in table "interactions" */
export type interactions_inc_input = {
		id?:number,
	match_score?:float8,
	user_id?:number
}

/** input type for inserting data into table "interactions" */
export type interactions_insert_input = {
		content?:string,
	content_type?:string,
	debug?:jsonb,
	embedding?:vector,
	events?:events_arr_rel_insert_input,
	id?:number,
	match_score?:float8,
	timestamp?:timestamptz,
	user_id?:number
}

/** aggregate max on columns */
export type interactions_max_fields = {
	__typename?: "interactions_max_fields",
	content?:string,
	content_type?:string,
	id?:number,
	match_score?:float8,
	timestamp?:timestamptz,
	user_id?:number
}

/** aggregate min on columns */
export type interactions_min_fields = {
	__typename?: "interactions_min_fields",
	content?:string,
	content_type?:string,
	id?:number,
	match_score?:float8,
	timestamp?:timestamptz,
	user_id?:number
}

/** response of any mutation on the table "interactions" */
export type interactions_mutation_response = {
	__typename?: "interactions_mutation_response",
	/** number of rows affected by the mutation */
	affected_rows:number,
	/** data from the rows affected by the mutation */
	returning:interactions[]
}

/** input type for inserting object relation for remote table "interactions" */
export type interactions_obj_rel_insert_input = {
		data:interactions_insert_input,
	/** upsert condition */
	on_conflict?:interactions_on_conflict
}

/** on_conflict condition type for table "interactions" */
export type interactions_on_conflict = {
		constraint:interactions_constraint,
	update_columns:interactions_update_column[],
	where?:interactions_bool_exp
}

/** Ordering options when selecting data from "interactions". */
export type interactions_order_by = {
		content?:order_by,
	content_type?:order_by,
	debug?:order_by,
	embedding?:order_by,
	events_aggregate?:events_aggregate_order_by,
	id?:order_by,
	match_score?:order_by,
	timestamp?:order_by,
	user_id?:order_by
}

/** primary key columns input for table: interactions */
export type interactions_pk_columns_input = {
		id:number
}

/** prepend existing jsonb value of filtered columns with new jsonb value */
export type interactions_prepend_input = {
		debug?:jsonb
}

/** select columns of table "interactions" */
export enum interactions_select_column {
	content = "content",
	content_type = "content_type",
	debug = "debug",
	embedding = "embedding",
	id = "id",
	match_score = "match_score",
	timestamp = "timestamp",
	user_id = "user_id"
}

/** input type for updating data in table "interactions" */
export type interactions_set_input = {
		content?:string,
	content_type?:string,
	debug?:jsonb,
	embedding?:vector,
	id?:number,
	match_score?:float8,
	timestamp?:timestamptz,
	user_id?:number
}

/** aggregate stddev on columns */
export type interactions_stddev_fields = {
	__typename?: "interactions_stddev_fields",
	id?:number,
	match_score?:number,
	user_id?:number
}

/** aggregate stddev_pop on columns */
export type interactions_stddev_pop_fields = {
	__typename?: "interactions_stddev_pop_fields",
	id?:number,
	match_score?:number,
	user_id?:number
}

/** aggregate stddev_samp on columns */
export type interactions_stddev_samp_fields = {
	__typename?: "interactions_stddev_samp_fields",
	id?:number,
	match_score?:number,
	user_id?:number
}

/** Streaming cursor of the table "interactions" */
export type interactions_stream_cursor_input = {
		/** Stream column input with initial value */
	initial_value:interactions_stream_cursor_value_input,
	/** cursor ordering */
	ordering?:cursor_ordering
}

/** Initial value of the column from where the streaming should start */
export type interactions_stream_cursor_value_input = {
		content?:string,
	content_type?:string,
	debug?:jsonb,
	embedding?:vector,
	id?:number,
	match_score?:float8,
	timestamp?:timestamptz,
	user_id?:number
}

/** aggregate sum on columns */
export type interactions_sum_fields = {
	__typename?: "interactions_sum_fields",
	id?:number,
	match_score?:float8,
	user_id?:number
}

/** update columns of table "interactions" */
export enum interactions_update_column {
	content = "content",
	content_type = "content_type",
	debug = "debug",
	embedding = "embedding",
	id = "id",
	match_score = "match_score",
	timestamp = "timestamp",
	user_id = "user_id"
}

export type interactions_updates = {
		/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:interactions_append_input,
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:interactions_delete_at_path_input,
	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:interactions_delete_elem_input,
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:interactions_delete_key_input,
	/** increments the numeric columns with given value of the filtered values */
	_inc?:interactions_inc_input,
	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:interactions_prepend_input,
	/** sets the columns of the filtered rows to the given values */
	_set?:interactions_set_input,
	/** filter the rows which have to be updated */
	where:interactions_bool_exp
}

/** aggregate var_pop on columns */
export type interactions_var_pop_fields = {
	__typename?: "interactions_var_pop_fields",
	id?:number,
	match_score?:number,
	user_id?:number
}

/** aggregate var_samp on columns */
export type interactions_var_samp_fields = {
	__typename?: "interactions_var_samp_fields",
	id?:number,
	match_score?:number,
	user_id?:number
}

/** aggregate variance on columns */
export type interactions_variance_fields = {
	__typename?: "interactions_variance_fields",
	id?:number,
	match_score?:number,
	user_id?:number
}

export type jsonb = any

export type jsonb_cast_exp = {
		String?:String_comparison_exp
}

/** Boolean expression to compare columns of type "jsonb". All fields are combined with logical 'AND'. */
export type jsonb_comparison_exp = {
		_cast?:jsonb_cast_exp,
	/** is the column contained in the given json value */
	_contained_in?:jsonb,
	/** does the column contain the given json value at the top level */
	_contains?:jsonb,
	_eq?:jsonb,
	_gt?:jsonb,
	_gte?:jsonb,
	/** does the string exist as a top-level key in the column */
	_has_key?:string,
	/** do all of these strings exist as top-level keys in the column */
	_has_keys_all?:string[],
	/** do any of these strings exist as top-level keys in the column */
	_has_keys_any?:string[],
	_in?:jsonb[],
	_is_null?:boolean,
	_lt?:jsonb,
	_lte?:jsonb,
	_neq?:jsonb,
	_nin?:jsonb[]
}

/** columns and relationships of "locations" */
export type locations = {
	__typename?: "locations",
	id:number,
	location:geography,
	name?:string,
	user_id:number
}

export type locations_aggregate = {
	__typename?: "locations_aggregate",
	aggregate?:locations_aggregate_fields,
	nodes:locations[]
}

export type locations_aggregate_bool_exp = {
		count?:locations_aggregate_bool_exp_count
}

export type locations_aggregate_bool_exp_count = {
		arguments?:locations_select_column[],
	distinct?:boolean,
	filter?:locations_bool_exp,
	predicate:Int_comparison_exp
}

/** aggregate fields of "locations" */
export type locations_aggregate_fields = {
	__typename?: "locations_aggregate_fields",
	avg?:locations_avg_fields,
	count:number,
	max?:locations_max_fields,
	min?:locations_min_fields,
	stddev?:locations_stddev_fields,
	stddev_pop?:locations_stddev_pop_fields,
	stddev_samp?:locations_stddev_samp_fields,
	sum?:locations_sum_fields,
	var_pop?:locations_var_pop_fields,
	var_samp?:locations_var_samp_fields,
	variance?:locations_variance_fields
}

/** order by aggregate values of table "locations" */
export type locations_aggregate_order_by = {
		avg?:locations_avg_order_by,
	count?:order_by,
	max?:locations_max_order_by,
	min?:locations_min_order_by,
	stddev?:locations_stddev_order_by,
	stddev_pop?:locations_stddev_pop_order_by,
	stddev_samp?:locations_stddev_samp_order_by,
	sum?:locations_sum_order_by,
	var_pop?:locations_var_pop_order_by,
	var_samp?:locations_var_samp_order_by,
	variance?:locations_variance_order_by
}

/** input type for inserting array relation for remote table "locations" */
export type locations_arr_rel_insert_input = {
		data:locations_insert_input[],
	/** upsert condition */
	on_conflict?:locations_on_conflict
}

/** aggregate avg on columns */
export type locations_avg_fields = {
	__typename?: "locations_avg_fields",
	id?:number,
	user_id?:number
}

/** order by avg() on columns of table "locations" */
export type locations_avg_order_by = {
		id?:order_by,
	user_id?:order_by
}

/** Boolean expression to filter rows from the table "locations". All fields are combined with a logical 'AND'. */
export type locations_bool_exp = {
		_and?:locations_bool_exp[],
	_not?:locations_bool_exp,
	_or?:locations_bool_exp[],
	id?:Int_comparison_exp,
	location?:geography_comparison_exp,
	name?:String_comparison_exp,
	user_id?:Int_comparison_exp
}

/** unique or primary key constraints on table "locations" */
export enum locations_constraint {
	locations_id_key = "locations_id_key",
	locations_pkey = "locations_pkey"
}

/** input type for incrementing numeric columns in table "locations" */
export type locations_inc_input = {
		id?:number,
	user_id?:number
}

/** input type for inserting data into table "locations" */
export type locations_insert_input = {
		id?:number,
	location?:geography,
	name?:string,
	user_id?:number
}

/** aggregate max on columns */
export type locations_max_fields = {
	__typename?: "locations_max_fields",
	id?:number,
	name?:string,
	user_id?:number
}

/** order by max() on columns of table "locations" */
export type locations_max_order_by = {
		id?:order_by,
	name?:order_by,
	user_id?:order_by
}

/** aggregate min on columns */
export type locations_min_fields = {
	__typename?: "locations_min_fields",
	id?:number,
	name?:string,
	user_id?:number
}

/** order by min() on columns of table "locations" */
export type locations_min_order_by = {
		id?:order_by,
	name?:order_by,
	user_id?:order_by
}

/** response of any mutation on the table "locations" */
export type locations_mutation_response = {
	__typename?: "locations_mutation_response",
	/** number of rows affected by the mutation */
	affected_rows:number,
	/** data from the rows affected by the mutation */
	returning:locations[]
}

/** on_conflict condition type for table "locations" */
export type locations_on_conflict = {
		constraint:locations_constraint,
	update_columns:locations_update_column[],
	where?:locations_bool_exp
}

/** Ordering options when selecting data from "locations". */
export type locations_order_by = {
		id?:order_by,
	location?:order_by,
	name?:order_by,
	user_id?:order_by
}

/** primary key columns input for table: locations */
export type locations_pk_columns_input = {
		id:number
}

/** select columns of table "locations" */
export enum locations_select_column {
	id = "id",
	location = "location",
	name = "name",
	user_id = "user_id"
}

/** input type for updating data in table "locations" */
export type locations_set_input = {
		id?:number,
	location?:geography,
	name?:string,
	user_id?:number
}

/** aggregate stddev on columns */
export type locations_stddev_fields = {
	__typename?: "locations_stddev_fields",
	id?:number,
	user_id?:number
}

/** order by stddev() on columns of table "locations" */
export type locations_stddev_order_by = {
		id?:order_by,
	user_id?:order_by
}

/** aggregate stddev_pop on columns */
export type locations_stddev_pop_fields = {
	__typename?: "locations_stddev_pop_fields",
	id?:number,
	user_id?:number
}

/** order by stddev_pop() on columns of table "locations" */
export type locations_stddev_pop_order_by = {
		id?:order_by,
	user_id?:order_by
}

/** aggregate stddev_samp on columns */
export type locations_stddev_samp_fields = {
	__typename?: "locations_stddev_samp_fields",
	id?:number,
	user_id?:number
}

/** order by stddev_samp() on columns of table "locations" */
export type locations_stddev_samp_order_by = {
		id?:order_by,
	user_id?:order_by
}

/** Streaming cursor of the table "locations" */
export type locations_stream_cursor_input = {
		/** Stream column input with initial value */
	initial_value:locations_stream_cursor_value_input,
	/** cursor ordering */
	ordering?:cursor_ordering
}

/** Initial value of the column from where the streaming should start */
export type locations_stream_cursor_value_input = {
		id?:number,
	location?:geography,
	name?:string,
	user_id?:number
}

/** aggregate sum on columns */
export type locations_sum_fields = {
	__typename?: "locations_sum_fields",
	id?:number,
	user_id?:number
}

/** order by sum() on columns of table "locations" */
export type locations_sum_order_by = {
		id?:order_by,
	user_id?:order_by
}

/** update columns of table "locations" */
export enum locations_update_column {
	id = "id",
	location = "location",
	name = "name",
	user_id = "user_id"
}

export type locations_updates = {
		/** increments the numeric columns with given value of the filtered values */
	_inc?:locations_inc_input,
	/** sets the columns of the filtered rows to the given values */
	_set?:locations_set_input,
	/** filter the rows which have to be updated */
	where:locations_bool_exp
}

/** aggregate var_pop on columns */
export type locations_var_pop_fields = {
	__typename?: "locations_var_pop_fields",
	id?:number,
	user_id?:number
}

/** order by var_pop() on columns of table "locations" */
export type locations_var_pop_order_by = {
		id?:order_by,
	user_id?:order_by
}

/** aggregate var_samp on columns */
export type locations_var_samp_fields = {
	__typename?: "locations_var_samp_fields",
	id?:number,
	user_id?:number
}

/** order by var_samp() on columns of table "locations" */
export type locations_var_samp_order_by = {
		id?:order_by,
	user_id?:order_by
}

/** aggregate variance on columns */
export type locations_variance_fields = {
	__typename?: "locations_variance_fields",
	id?:number,
	user_id?:number
}

/** order by variance() on columns of table "locations" */
export type locations_variance_order_by = {
		id?:order_by,
	user_id?:order_by
}

export type match_interactions_args = {
		match_threshold?:float8,
	query_embedding?:vector,
	target_user_id?:number
}

/** mutation root */
export type mutation_root = {
	__typename?: "mutation_root",
	/** delete data from the table: "associations" */
	delete_associations?:associations_mutation_response,
	/** delete single row from the table: "associations" */
	delete_associations_by_pk?:associations,
	/** delete data from the table: "event_tag" */
	delete_event_tag?:event_tag_mutation_response,
	/** delete single row from the table: "event_tag" */
	delete_event_tag_by_pk?:event_tag,
	/** delete data from the table: "event_types" */
	delete_event_types?:event_types_mutation_response,
	/** delete single row from the table: "event_types" */
	delete_event_types_by_pk?:event_types,
	/** delete data from the table: "events" */
	delete_events?:events_mutation_response,
	/** delete single row from the table: "events" */
	delete_events_by_pk?:events,
	/** delete data from the table: "goals" */
	delete_goals?:goals_mutation_response,
	/** delete single row from the table: "goals" */
	delete_goals_by_pk?:goals,
	/** delete data from the table: "interactions" */
	delete_interactions?:interactions_mutation_response,
	/** delete single row from the table: "interactions" */
	delete_interactions_by_pk?:interactions,
	/** delete data from the table: "locations" */
	delete_locations?:locations_mutation_response,
	/** delete single row from the table: "locations" */
	delete_locations_by_pk?:locations,
	/** delete data from the table: "object_types" */
	delete_object_types?:object_types_mutation_response,
	/** delete single row from the table: "object_types" */
	delete_object_types_by_pk?:object_types,
	/** delete data from the table: "objects" */
	delete_objects?:objects_mutation_response,
	/** delete single row from the table: "objects" */
	delete_objects_by_pk?:objects,
	/** delete data from the table: "todos" */
	delete_todos?:todos_mutation_response,
	/** delete single row from the table: "todos" */
	delete_todos_by_pk?:todos,
	/** delete data from the table: "users" */
	delete_users?:users_mutation_response,
	/** delete single row from the table: "users" */
	delete_users_by_pk?:users,
	/** insert data into the table: "associations" */
	insert_associations?:associations_mutation_response,
	/** insert a single row into the table: "associations" */
	insert_associations_one?:associations,
	/** insert data into the table: "event_tag" */
	insert_event_tag?:event_tag_mutation_response,
	/** insert a single row into the table: "event_tag" */
	insert_event_tag_one?:event_tag,
	/** insert data into the table: "event_types" */
	insert_event_types?:event_types_mutation_response,
	/** insert a single row into the table: "event_types" */
	insert_event_types_one?:event_types,
	/** insert data into the table: "events" */
	insert_events?:events_mutation_response,
	/** insert a single row into the table: "events" */
	insert_events_one?:events,
	/** insert data into the table: "goals" */
	insert_goals?:goals_mutation_response,
	/** insert a single row into the table: "goals" */
	insert_goals_one?:goals,
	/** insert data into the table: "interactions" */
	insert_interactions?:interactions_mutation_response,
	/** insert a single row into the table: "interactions" */
	insert_interactions_one?:interactions,
	/** insert data into the table: "locations" */
	insert_locations?:locations_mutation_response,
	/** insert a single row into the table: "locations" */
	insert_locations_one?:locations,
	/** insert data into the table: "object_types" */
	insert_object_types?:object_types_mutation_response,
	/** insert a single row into the table: "object_types" */
	insert_object_types_one?:object_types,
	/** insert data into the table: "objects" */
	insert_objects?:objects_mutation_response,
	/** insert a single row into the table: "objects" */
	insert_objects_one?:objects,
	/** insert data into the table: "todos" */
	insert_todos?:todos_mutation_response,
	/** insert a single row into the table: "todos" */
	insert_todos_one?:todos,
	/** insert data into the table: "users" */
	insert_users?:users_mutation_response,
	/** insert a single row into the table: "users" */
	insert_users_one?:users,
	/** update data of the table: "associations" */
	update_associations?:associations_mutation_response,
	/** update single row of the table: "associations" */
	update_associations_by_pk?:associations,
	/** update multiples rows of table: "associations" */
	update_associations_many?:(associations_mutation_response | undefined)[],
	/** update data of the table: "event_tag" */
	update_event_tag?:event_tag_mutation_response,
	/** update single row of the table: "event_tag" */
	update_event_tag_by_pk?:event_tag,
	/** update multiples rows of table: "event_tag" */
	update_event_tag_many?:(event_tag_mutation_response | undefined)[],
	/** update data of the table: "event_types" */
	update_event_types?:event_types_mutation_response,
	/** update single row of the table: "event_types" */
	update_event_types_by_pk?:event_types,
	/** update multiples rows of table: "event_types" */
	update_event_types_many?:(event_types_mutation_response | undefined)[],
	/** update data of the table: "events" */
	update_events?:events_mutation_response,
	/** update single row of the table: "events" */
	update_events_by_pk?:events,
	/** update multiples rows of table: "events" */
	update_events_many?:(events_mutation_response | undefined)[],
	/** update data of the table: "goals" */
	update_goals?:goals_mutation_response,
	/** update single row of the table: "goals" */
	update_goals_by_pk?:goals,
	/** update multiples rows of table: "goals" */
	update_goals_many?:(goals_mutation_response | undefined)[],
	/** update data of the table: "interactions" */
	update_interactions?:interactions_mutation_response,
	/** update single row of the table: "interactions" */
	update_interactions_by_pk?:interactions,
	/** update multiples rows of table: "interactions" */
	update_interactions_many?:(interactions_mutation_response | undefined)[],
	/** update data of the table: "locations" */
	update_locations?:locations_mutation_response,
	/** update single row of the table: "locations" */
	update_locations_by_pk?:locations,
	/** update multiples rows of table: "locations" */
	update_locations_many?:(locations_mutation_response | undefined)[],
	/** update data of the table: "object_types" */
	update_object_types?:object_types_mutation_response,
	/** update single row of the table: "object_types" */
	update_object_types_by_pk?:object_types,
	/** update multiples rows of table: "object_types" */
	update_object_types_many?:(object_types_mutation_response | undefined)[],
	/** update data of the table: "objects" */
	update_objects?:objects_mutation_response,
	/** update single row of the table: "objects" */
	update_objects_by_pk?:objects,
	/** update multiples rows of table: "objects" */
	update_objects_many?:(objects_mutation_response | undefined)[],
	/** update data of the table: "todos" */
	update_todos?:todos_mutation_response,
	/** update single row of the table: "todos" */
	update_todos_by_pk?:todos,
	/** update multiples rows of table: "todos" */
	update_todos_many?:(todos_mutation_response | undefined)[],
	/** update data of the table: "users" */
	update_users?:users_mutation_response,
	/** update single row of the table: "users" */
	update_users_by_pk?:users,
	/** update multiples rows of table: "users" */
	update_users_many?:(users_mutation_response | undefined)[]
}

/** columns and relationships of "object_types" */
export type object_types = {
	__typename?: "object_types",
	id:string,
	metadata:jsonb
}

/** aggregated selection of "object_types" */
export type object_types_aggregate = {
	__typename?: "object_types_aggregate",
	aggregate?:object_types_aggregate_fields,
	nodes:object_types[]
}

/** aggregate fields of "object_types" */
export type object_types_aggregate_fields = {
	__typename?: "object_types_aggregate_fields",
	count:number,
	max?:object_types_max_fields,
	min?:object_types_min_fields
}

/** append existing jsonb value of filtered columns with new jsonb value */
export type object_types_append_input = {
		metadata?:jsonb
}

/** Boolean expression to filter rows from the table "object_types". All fields are combined with a logical 'AND'. */
export type object_types_bool_exp = {
		_and?:object_types_bool_exp[],
	_not?:object_types_bool_exp,
	_or?:object_types_bool_exp[],
	id?:String_comparison_exp,
	metadata?:jsonb_comparison_exp
}

/** unique or primary key constraints on table "object_types" */
export enum object_types_constraint {
	object_types_pkey = "object_types_pkey"
}

/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
export type object_types_delete_at_path_input = {
		metadata?:string[]
}

/** delete the array element with specified index (negative integers count from the
end). throws an error if top level container is not an array */
export type object_types_delete_elem_input = {
		metadata?:number
}

/** delete key/value pair or string element. key/value pairs are matched based on their key value */
export type object_types_delete_key_input = {
		metadata?:string
}

/** input type for inserting data into table "object_types" */
export type object_types_insert_input = {
		id?:string,
	metadata?:jsonb
}

/** aggregate max on columns */
export type object_types_max_fields = {
	__typename?: "object_types_max_fields",
	id?:string
}

/** aggregate min on columns */
export type object_types_min_fields = {
	__typename?: "object_types_min_fields",
	id?:string
}

/** response of any mutation on the table "object_types" */
export type object_types_mutation_response = {
	__typename?: "object_types_mutation_response",
	/** number of rows affected by the mutation */
	affected_rows:number,
	/** data from the rows affected by the mutation */
	returning:object_types[]
}

/** on_conflict condition type for table "object_types" */
export type object_types_on_conflict = {
		constraint:object_types_constraint,
	update_columns:object_types_update_column[],
	where?:object_types_bool_exp
}

/** Ordering options when selecting data from "object_types". */
export type object_types_order_by = {
		id?:order_by,
	metadata?:order_by
}

/** primary key columns input for table: object_types */
export type object_types_pk_columns_input = {
		id:string
}

/** prepend existing jsonb value of filtered columns with new jsonb value */
export type object_types_prepend_input = {
		metadata?:jsonb
}

/** select columns of table "object_types" */
export enum object_types_select_column {
	id = "id",
	metadata = "metadata"
}

/** input type for updating data in table "object_types" */
export type object_types_set_input = {
		id?:string,
	metadata?:jsonb
}

/** Streaming cursor of the table "object_types" */
export type object_types_stream_cursor_input = {
		/** Stream column input with initial value */
	initial_value:object_types_stream_cursor_value_input,
	/** cursor ordering */
	ordering?:cursor_ordering
}

/** Initial value of the column from where the streaming should start */
export type object_types_stream_cursor_value_input = {
		id?:string,
	metadata?:jsonb
}

/** update columns of table "object_types" */
export enum object_types_update_column {
	id = "id",
	metadata = "metadata"
}

export type object_types_updates = {
		/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:object_types_append_input,
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:object_types_delete_at_path_input,
	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:object_types_delete_elem_input,
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:object_types_delete_key_input,
	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:object_types_prepend_input,
	/** sets the columns of the filtered rows to the given values */
	_set?:object_types_set_input,
	/** filter the rows which have to be updated */
	where:object_types_bool_exp
}

/** columns and relationships of "objects" */
export type objects = {
	__typename?: "objects",
	id:number,
	name:string,
	object_type:string
}

/** aggregated selection of "objects" */
export type objects_aggregate = {
	__typename?: "objects_aggregate",
	aggregate?:objects_aggregate_fields,
	nodes:objects[]
}

/** aggregate fields of "objects" */
export type objects_aggregate_fields = {
	__typename?: "objects_aggregate_fields",
	avg?:objects_avg_fields,
	count:number,
	max?:objects_max_fields,
	min?:objects_min_fields,
	stddev?:objects_stddev_fields,
	stddev_pop?:objects_stddev_pop_fields,
	stddev_samp?:objects_stddev_samp_fields,
	sum?:objects_sum_fields,
	var_pop?:objects_var_pop_fields,
	var_samp?:objects_var_samp_fields,
	variance?:objects_variance_fields
}

/** aggregate avg on columns */
export type objects_avg_fields = {
	__typename?: "objects_avg_fields",
	id?:number
}

/** Boolean expression to filter rows from the table "objects". All fields are combined with a logical 'AND'. */
export type objects_bool_exp = {
		_and?:objects_bool_exp[],
	_not?:objects_bool_exp,
	_or?:objects_bool_exp[],
	id?:Int_comparison_exp,
	name?:String_comparison_exp,
	object_type?:String_comparison_exp
}

/** unique or primary key constraints on table "objects" */
export enum objects_constraint {
	objects_pkey = "objects_pkey"
}

/** input type for incrementing numeric columns in table "objects" */
export type objects_inc_input = {
		id?:number
}

/** input type for inserting data into table "objects" */
export type objects_insert_input = {
		id?:number,
	name?:string,
	object_type?:string
}

/** aggregate max on columns */
export type objects_max_fields = {
	__typename?: "objects_max_fields",
	id?:number,
	name?:string,
	object_type?:string
}

/** aggregate min on columns */
export type objects_min_fields = {
	__typename?: "objects_min_fields",
	id?:number,
	name?:string,
	object_type?:string
}

/** response of any mutation on the table "objects" */
export type objects_mutation_response = {
	__typename?: "objects_mutation_response",
	/** number of rows affected by the mutation */
	affected_rows:number,
	/** data from the rows affected by the mutation */
	returning:objects[]
}

/** on_conflict condition type for table "objects" */
export type objects_on_conflict = {
		constraint:objects_constraint,
	update_columns:objects_update_column[],
	where?:objects_bool_exp
}

/** Ordering options when selecting data from "objects". */
export type objects_order_by = {
		id?:order_by,
	name?:order_by,
	object_type?:order_by
}

/** primary key columns input for table: objects */
export type objects_pk_columns_input = {
		id:number
}

/** select columns of table "objects" */
export enum objects_select_column {
	id = "id",
	name = "name",
	object_type = "object_type"
}

/** input type for updating data in table "objects" */
export type objects_set_input = {
		id?:number,
	name?:string,
	object_type?:string
}

/** aggregate stddev on columns */
export type objects_stddev_fields = {
	__typename?: "objects_stddev_fields",
	id?:number
}

/** aggregate stddev_pop on columns */
export type objects_stddev_pop_fields = {
	__typename?: "objects_stddev_pop_fields",
	id?:number
}

/** aggregate stddev_samp on columns */
export type objects_stddev_samp_fields = {
	__typename?: "objects_stddev_samp_fields",
	id?:number
}

/** Streaming cursor of the table "objects" */
export type objects_stream_cursor_input = {
		/** Stream column input with initial value */
	initial_value:objects_stream_cursor_value_input,
	/** cursor ordering */
	ordering?:cursor_ordering
}

/** Initial value of the column from where the streaming should start */
export type objects_stream_cursor_value_input = {
		id?:number,
	name?:string,
	object_type?:string
}

/** aggregate sum on columns */
export type objects_sum_fields = {
	__typename?: "objects_sum_fields",
	id?:number
}

/** update columns of table "objects" */
export enum objects_update_column {
	id = "id",
	name = "name",
	object_type = "object_type"
}

export type objects_updates = {
		/** increments the numeric columns with given value of the filtered values */
	_inc?:objects_inc_input,
	/** sets the columns of the filtered rows to the given values */
	_set?:objects_set_input,
	/** filter the rows which have to be updated */
	where:objects_bool_exp
}

/** aggregate var_pop on columns */
export type objects_var_pop_fields = {
	__typename?: "objects_var_pop_fields",
	id?:number
}

/** aggregate var_samp on columns */
export type objects_var_samp_fields = {
	__typename?: "objects_var_samp_fields",
	id?:number
}

/** aggregate variance on columns */
export type objects_variance_fields = {
	__typename?: "objects_variance_fields",
	id?:number
}

/** column ordering options */
export enum order_by {
	asc = "asc",
	asc_nulls_first = "asc_nulls_first",
	asc_nulls_last = "asc_nulls_last",
	desc = "desc",
	desc_nulls_first = "desc_nulls_first",
	desc_nulls_last = "desc_nulls_last"
}

export type query_root = {
	__typename?: "query_root",
	/** fetch data from the table: "associations" */
	associations:associations[],
	/** fetch aggregated fields from the table: "associations" */
	associations_aggregate:associations_aggregate,
	/** fetch data from the table: "associations" using primary key columns */
	associations_by_pk?:associations,
	/** execute function "closest_user_location" which returns "locations" */
	closest_user_location:locations[],
	/** execute function "closest_user_location" and query aggregates on result of table type "locations" */
	closest_user_location_aggregate:locations_aggregate,
	/** fetch data from the table: "event_tag" */
	event_tag:event_tag[],
	/** fetch aggregated fields from the table: "event_tag" */
	event_tag_aggregate:event_tag_aggregate,
	/** fetch data from the table: "event_tag" using primary key columns */
	event_tag_by_pk?:event_tag,
	/** fetch data from the table: "event_types" */
	event_types:event_types[],
	/** fetch aggregated fields from the table: "event_types" */
	event_types_aggregate:event_types_aggregate,
	/** fetch data from the table: "event_types" using primary key columns */
	event_types_by_pk?:event_types,
	/** An array relationship */
	events:events[],
	/** An aggregate relationship */
	events_aggregate:events_aggregate,
	/** fetch data from the table: "events" using primary key columns */
	events_by_pk?:events,
	/** execute function "fetch_associations" which returns "associations" */
	fetch_associations:associations[],
	/** execute function "fetch_associations" and query aggregates on result of table type "associations" */
	fetch_associations_aggregate:associations_aggregate,
	/** fetch data from the table: "goals" */
	goals:goals[],
	/** fetch aggregated fields from the table: "goals" */
	goals_aggregate:goals_aggregate,
	/** fetch data from the table: "goals" using primary key columns */
	goals_by_pk?:goals,
	/** fetch data from the table: "interactions" */
	interactions:interactions[],
	/** fetch aggregated fields from the table: "interactions" */
	interactions_aggregate:interactions_aggregate,
	/** fetch data from the table: "interactions" using primary key columns */
	interactions_by_pk?:interactions,
	/** An array relationship */
	locations:locations[],
	/** An aggregate relationship */
	locations_aggregate:locations_aggregate,
	/** fetch data from the table: "locations" using primary key columns */
	locations_by_pk?:locations,
	/** execute function "match_interactions" which returns "interactions" */
	match_interactions:interactions[],
	/** execute function "match_interactions" and query aggregates on result of table type "interactions" */
	match_interactions_aggregate:interactions_aggregate,
	/** fetch data from the table: "object_types" */
	object_types:object_types[],
	/** fetch aggregated fields from the table: "object_types" */
	object_types_aggregate:object_types_aggregate,
	/** fetch data from the table: "object_types" using primary key columns */
	object_types_by_pk?:object_types,
	/** fetch data from the table: "objects" */
	objects:objects[],
	/** fetch aggregated fields from the table: "objects" */
	objects_aggregate:objects_aggregate,
	/** fetch data from the table: "objects" using primary key columns */
	objects_by_pk?:objects,
	/** fetch data from the table: "todos" */
	todos:todos[],
	/** fetch aggregated fields from the table: "todos" */
	todos_aggregate:todos_aggregate,
	/** fetch data from the table: "todos" using primary key columns */
	todos_by_pk?:todos,
	/** fetch data from the table: "users" */
	users:users[],
	/** fetch aggregated fields from the table: "users" */
	users_aggregate:users_aggregate,
	/** fetch data from the table: "users" using primary key columns */
	users_by_pk?:users
}

export type st_d_within_geography_input = {
		distance:number,
	from:geography,
	use_spheroid?:boolean
}

export type st_d_within_input = {
		distance:number,
	from:geometry
}

/** Boolean expression to compare columns of type "String". All fields are combined with logical 'AND'. */
export type String_comparison_exp = {
		_eq?:string,
	_gt?:string,
	_gte?:string,
	/** does the column match the given case-insensitive pattern */
	_ilike?:string,
	_in?:string[],
	/** does the column match the given POSIX regular expression, case insensitive */
	_iregex?:string,
	_is_null?:boolean,
	/** does the column match the given pattern */
	_like?:string,
	_lt?:string,
	_lte?:string,
	_neq?:string,
	/** does the column NOT match the given case-insensitive pattern */
	_nilike?:string,
	_nin?:string[],
	/** does the column NOT match the given POSIX regular expression, case insensitive */
	_niregex?:string,
	/** does the column NOT match the given pattern */
	_nlike?:string,
	/** does the column NOT match the given POSIX regular expression, case sensitive */
	_nregex?:string,
	/** does the column NOT match the given SQL regular expression */
	_nsimilar?:string,
	/** does the column match the given POSIX regular expression, case sensitive */
	_regex?:string,
	/** does the column match the given SQL regular expression */
	_similar?:string
}

export type subscription_root = {
	__typename?: "subscription_root",
	/** fetch data from the table: "associations" */
	associations:associations[],
	/** fetch aggregated fields from the table: "associations" */
	associations_aggregate:associations_aggregate,
	/** fetch data from the table: "associations" using primary key columns */
	associations_by_pk?:associations,
	/** fetch data from the table in a streaming manner: "associations" */
	associations_stream:associations[],
	/** execute function "closest_user_location" which returns "locations" */
	closest_user_location:locations[],
	/** execute function "closest_user_location" and query aggregates on result of table type "locations" */
	closest_user_location_aggregate:locations_aggregate,
	/** fetch data from the table: "event_tag" */
	event_tag:event_tag[],
	/** fetch aggregated fields from the table: "event_tag" */
	event_tag_aggregate:event_tag_aggregate,
	/** fetch data from the table: "event_tag" using primary key columns */
	event_tag_by_pk?:event_tag,
	/** fetch data from the table in a streaming manner: "event_tag" */
	event_tag_stream:event_tag[],
	/** fetch data from the table: "event_types" */
	event_types:event_types[],
	/** fetch aggregated fields from the table: "event_types" */
	event_types_aggregate:event_types_aggregate,
	/** fetch data from the table: "event_types" using primary key columns */
	event_types_by_pk?:event_types,
	/** fetch data from the table in a streaming manner: "event_types" */
	event_types_stream:event_types[],
	/** An array relationship */
	events:events[],
	/** An aggregate relationship */
	events_aggregate:events_aggregate,
	/** fetch data from the table: "events" using primary key columns */
	events_by_pk?:events,
	/** fetch data from the table in a streaming manner: "events" */
	events_stream:events[],
	/** execute function "fetch_associations" which returns "associations" */
	fetch_associations:associations[],
	/** execute function "fetch_associations" and query aggregates on result of table type "associations" */
	fetch_associations_aggregate:associations_aggregate,
	/** fetch data from the table: "goals" */
	goals:goals[],
	/** fetch aggregated fields from the table: "goals" */
	goals_aggregate:goals_aggregate,
	/** fetch data from the table: "goals" using primary key columns */
	goals_by_pk?:goals,
	/** fetch data from the table in a streaming manner: "goals" */
	goals_stream:goals[],
	/** fetch data from the table: "interactions" */
	interactions:interactions[],
	/** fetch aggregated fields from the table: "interactions" */
	interactions_aggregate:interactions_aggregate,
	/** fetch data from the table: "interactions" using primary key columns */
	interactions_by_pk?:interactions,
	/** fetch data from the table in a streaming manner: "interactions" */
	interactions_stream:interactions[],
	/** An array relationship */
	locations:locations[],
	/** An aggregate relationship */
	locations_aggregate:locations_aggregate,
	/** fetch data from the table: "locations" using primary key columns */
	locations_by_pk?:locations,
	/** fetch data from the table in a streaming manner: "locations" */
	locations_stream:locations[],
	/** execute function "match_interactions" which returns "interactions" */
	match_interactions:interactions[],
	/** execute function "match_interactions" and query aggregates on result of table type "interactions" */
	match_interactions_aggregate:interactions_aggregate,
	/** fetch data from the table: "object_types" */
	object_types:object_types[],
	/** fetch aggregated fields from the table: "object_types" */
	object_types_aggregate:object_types_aggregate,
	/** fetch data from the table: "object_types" using primary key columns */
	object_types_by_pk?:object_types,
	/** fetch data from the table in a streaming manner: "object_types" */
	object_types_stream:object_types[],
	/** fetch data from the table: "objects" */
	objects:objects[],
	/** fetch aggregated fields from the table: "objects" */
	objects_aggregate:objects_aggregate,
	/** fetch data from the table: "objects" using primary key columns */
	objects_by_pk?:objects,
	/** fetch data from the table in a streaming manner: "objects" */
	objects_stream:objects[],
	/** fetch data from the table: "todos" */
	todos:todos[],
	/** fetch aggregated fields from the table: "todos" */
	todos_aggregate:todos_aggregate,
	/** fetch data from the table: "todos" using primary key columns */
	todos_by_pk?:todos,
	/** fetch data from the table in a streaming manner: "todos" */
	todos_stream:todos[],
	/** fetch data from the table: "users" */
	users:users[],
	/** fetch aggregated fields from the table: "users" */
	users_aggregate:users_aggregate,
	/** fetch data from the table: "users" using primary key columns */
	users_by_pk?:users,
	/** fetch data from the table in a streaming manner: "users" */
	users_stream:users[]
}

export type timestamp = any

/** Boolean expression to compare columns of type "timestamp". All fields are combined with logical 'AND'. */
export type timestamp_comparison_exp = {
		_eq?:timestamp,
	_gt?:timestamp,
	_gte?:timestamp,
	_in?:timestamp[],
	_is_null?:boolean,
	_lt?:timestamp,
	_lte?:timestamp,
	_neq?:timestamp,
	_nin?:timestamp[]
}

export type timestamptz = any

/** Boolean expression to compare columns of type "timestamptz". All fields are combined with logical 'AND'. */
export type timestamptz_comparison_exp = {
		_eq?:timestamptz,
	_gt?:timestamptz,
	_gte?:timestamptz,
	_in?:timestamptz[],
	_is_null?:boolean,
	_lt?:timestamptz,
	_lte?:timestamptz,
	_neq?:timestamptz,
	_nin?:timestamptz[]
}

/** columns and relationships of "todos" */
export type todos = {
	__typename?: "todos",
	current_count?:number,
	done_as_expected?:boolean,
	due:timestamptz,
	/** An object relationship */
	goal?:goals,
	goal_id?:number,
	id:number,
	name:string,
	status:string,
	updated:timestamptz,
	/** An object relationship */
	user:users,
	user_id:number
}

/** aggregated selection of "todos" */
export type todos_aggregate = {
	__typename?: "todos_aggregate",
	aggregate?:todos_aggregate_fields,
	nodes:todos[]
}

/** aggregate fields of "todos" */
export type todos_aggregate_fields = {
	__typename?: "todos_aggregate_fields",
	avg?:todos_avg_fields,
	count:number,
	max?:todos_max_fields,
	min?:todos_min_fields,
	stddev?:todos_stddev_fields,
	stddev_pop?:todos_stddev_pop_fields,
	stddev_samp?:todos_stddev_samp_fields,
	sum?:todos_sum_fields,
	var_pop?:todos_var_pop_fields,
	var_samp?:todos_var_samp_fields,
	variance?:todos_variance_fields
}

/** aggregate avg on columns */
export type todos_avg_fields = {
	__typename?: "todos_avg_fields",
	current_count?:number,
	goal_id?:number,
	id?:number,
	user_id?:number
}

/** Boolean expression to filter rows from the table "todos". All fields are combined with a logical 'AND'. */
export type todos_bool_exp = {
		_and?:todos_bool_exp[],
	_not?:todos_bool_exp,
	_or?:todos_bool_exp[],
	current_count?:Int_comparison_exp,
	done_as_expected?:Boolean_comparison_exp,
	due?:timestamptz_comparison_exp,
	goal?:goals_bool_exp,
	goal_id?:Int_comparison_exp,
	id?:Int_comparison_exp,
	name?:String_comparison_exp,
	status?:String_comparison_exp,
	updated?:timestamptz_comparison_exp,
	user?:users_bool_exp,
	user_id?:Int_comparison_exp
}

/** unique or primary key constraints on table "todos" */
export enum todos_constraint {
	todo_goal_id_user_id_key = "todo_goal_id_user_id_key",
	todo_pkey = "todo_pkey"
}

/** input type for incrementing numeric columns in table "todos" */
export type todos_inc_input = {
		current_count?:number,
	goal_id?:number,
	id?:number,
	user_id?:number
}

/** input type for inserting data into table "todos" */
export type todos_insert_input = {
		current_count?:number,
	done_as_expected?:boolean,
	due?:timestamptz,
	goal?:goals_obj_rel_insert_input,
	goal_id?:number,
	id?:number,
	name?:string,
	status?:string,
	updated?:timestamptz,
	user?:users_obj_rel_insert_input,
	user_id?:number
}

/** aggregate max on columns */
export type todos_max_fields = {
	__typename?: "todos_max_fields",
	current_count?:number,
	due?:timestamptz,
	goal_id?:number,
	id?:number,
	name?:string,
	status?:string,
	updated?:timestamptz,
	user_id?:number
}

/** aggregate min on columns */
export type todos_min_fields = {
	__typename?: "todos_min_fields",
	current_count?:number,
	due?:timestamptz,
	goal_id?:number,
	id?:number,
	name?:string,
	status?:string,
	updated?:timestamptz,
	user_id?:number
}

/** response of any mutation on the table "todos" */
export type todos_mutation_response = {
	__typename?: "todos_mutation_response",
	/** number of rows affected by the mutation */
	affected_rows:number,
	/** data from the rows affected by the mutation */
	returning:todos[]
}

/** input type for inserting object relation for remote table "todos" */
export type todos_obj_rel_insert_input = {
		data:todos_insert_input,
	/** upsert condition */
	on_conflict?:todos_on_conflict
}

/** on_conflict condition type for table "todos" */
export type todos_on_conflict = {
		constraint:todos_constraint,
	update_columns:todos_update_column[],
	where?:todos_bool_exp
}

/** Ordering options when selecting data from "todos". */
export type todos_order_by = {
		current_count?:order_by,
	done_as_expected?:order_by,
	due?:order_by,
	goal?:goals_order_by,
	goal_id?:order_by,
	id?:order_by,
	name?:order_by,
	status?:order_by,
	updated?:order_by,
	user?:users_order_by,
	user_id?:order_by
}

/** primary key columns input for table: todos */
export type todos_pk_columns_input = {
		id:number
}

/** select columns of table "todos" */
export enum todos_select_column {
	current_count = "current_count",
	done_as_expected = "done_as_expected",
	due = "due",
	goal_id = "goal_id",
	id = "id",
	name = "name",
	status = "status",
	updated = "updated",
	user_id = "user_id"
}

/** input type for updating data in table "todos" */
export type todos_set_input = {
		current_count?:number,
	done_as_expected?:boolean,
	due?:timestamptz,
	goal_id?:number,
	id?:number,
	name?:string,
	status?:string,
	updated?:timestamptz,
	user_id?:number
}

/** aggregate stddev on columns */
export type todos_stddev_fields = {
	__typename?: "todos_stddev_fields",
	current_count?:number,
	goal_id?:number,
	id?:number,
	user_id?:number
}

/** aggregate stddev_pop on columns */
export type todos_stddev_pop_fields = {
	__typename?: "todos_stddev_pop_fields",
	current_count?:number,
	goal_id?:number,
	id?:number,
	user_id?:number
}

/** aggregate stddev_samp on columns */
export type todos_stddev_samp_fields = {
	__typename?: "todos_stddev_samp_fields",
	current_count?:number,
	goal_id?:number,
	id?:number,
	user_id?:number
}

/** Streaming cursor of the table "todos" */
export type todos_stream_cursor_input = {
		/** Stream column input with initial value */
	initial_value:todos_stream_cursor_value_input,
	/** cursor ordering */
	ordering?:cursor_ordering
}

/** Initial value of the column from where the streaming should start */
export type todos_stream_cursor_value_input = {
		current_count?:number,
	done_as_expected?:boolean,
	due?:timestamptz,
	goal_id?:number,
	id?:number,
	name?:string,
	status?:string,
	updated?:timestamptz,
	user_id?:number
}

/** aggregate sum on columns */
export type todos_sum_fields = {
	__typename?: "todos_sum_fields",
	current_count?:number,
	goal_id?:number,
	id?:number,
	user_id?:number
}

/** update columns of table "todos" */
export enum todos_update_column {
	current_count = "current_count",
	done_as_expected = "done_as_expected",
	due = "due",
	goal_id = "goal_id",
	id = "id",
	name = "name",
	status = "status",
	updated = "updated",
	user_id = "user_id"
}

export type todos_updates = {
		/** increments the numeric columns with given value of the filtered values */
	_inc?:todos_inc_input,
	/** sets the columns of the filtered rows to the given values */
	_set?:todos_set_input,
	/** filter the rows which have to be updated */
	where:todos_bool_exp
}

/** aggregate var_pop on columns */
export type todos_var_pop_fields = {
	__typename?: "todos_var_pop_fields",
	current_count?:number,
	goal_id?:number,
	id?:number,
	user_id?:number
}

/** aggregate var_samp on columns */
export type todos_var_samp_fields = {
	__typename?: "todos_var_samp_fields",
	current_count?:number,
	goal_id?:number,
	id?:number,
	user_id?:number
}

/** aggregate variance on columns */
export type todos_variance_fields = {
	__typename?: "todos_variance_fields",
	current_count?:number,
	goal_id?:number,
	id?:number,
	user_id?:number
}

/** columns and relationships of "users" */
export type users = {
	__typename?: "users",
	apple_id?:string,
	/** A computed field, executes function "closest_user_location" */
	closest_user_location?:locations[],
	config:jsonb,
	/** An array relationship */
	events:events[],
	/** An aggregate relationship */
	events_aggregate:events_aggregate,
	id:number,
	language:string,
	/** An array relationship */
	locations:locations[],
	/** An aggregate relationship */
	locations_aggregate:locations_aggregate,
	name:string,
	timezone?:string
}

/** aggregated selection of "users" */
export type users_aggregate = {
	__typename?: "users_aggregate",
	aggregate?:users_aggregate_fields,
	nodes:users[]
}

/** aggregate fields of "users" */
export type users_aggregate_fields = {
	__typename?: "users_aggregate_fields",
	avg?:users_avg_fields,
	count:number,
	max?:users_max_fields,
	min?:users_min_fields,
	stddev?:users_stddev_fields,
	stddev_pop?:users_stddev_pop_fields,
	stddev_samp?:users_stddev_samp_fields,
	sum?:users_sum_fields,
	var_pop?:users_var_pop_fields,
	var_samp?:users_var_samp_fields,
	variance?:users_variance_fields
}

/** append existing jsonb value of filtered columns with new jsonb value */
export type users_append_input = {
		config?:jsonb
}

/** aggregate avg on columns */
export type users_avg_fields = {
	__typename?: "users_avg_fields",
	id?:number
}

/** Boolean expression to filter rows from the table "users". All fields are combined with a logical 'AND'. */
export type users_bool_exp = {
		_and?:users_bool_exp[],
	_not?:users_bool_exp,
	_or?:users_bool_exp[],
	apple_id?:String_comparison_exp,
	config?:jsonb_comparison_exp,
	events?:events_bool_exp,
	events_aggregate?:events_aggregate_bool_exp,
	id?:Int_comparison_exp,
	language?:String_comparison_exp,
	locations?:locations_bool_exp,
	locations_aggregate?:locations_aggregate_bool_exp,
	name?:String_comparison_exp,
	timezone?:String_comparison_exp
}

/** unique or primary key constraints on table "users" */
export enum users_constraint {
	user_pkey = "user_pkey"
}

/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
export type users_delete_at_path_input = {
		config?:string[]
}

/** delete the array element with specified index (negative integers count from the
end). throws an error if top level container is not an array */
export type users_delete_elem_input = {
		config?:number
}

/** delete key/value pair or string element. key/value pairs are matched based on their key value */
export type users_delete_key_input = {
		config?:string
}

/** input type for incrementing numeric columns in table "users" */
export type users_inc_input = {
		id?:number
}

/** input type for inserting data into table "users" */
export type users_insert_input = {
		apple_id?:string,
	config?:jsonb,
	events?:events_arr_rel_insert_input,
	id?:number,
	language?:string,
	locations?:locations_arr_rel_insert_input,
	name?:string,
	timezone?:string
}

/** aggregate max on columns */
export type users_max_fields = {
	__typename?: "users_max_fields",
	apple_id?:string,
	id?:number,
	language?:string,
	name?:string,
	timezone?:string
}

/** aggregate min on columns */
export type users_min_fields = {
	__typename?: "users_min_fields",
	apple_id?:string,
	id?:number,
	language?:string,
	name?:string,
	timezone?:string
}

/** response of any mutation on the table "users" */
export type users_mutation_response = {
	__typename?: "users_mutation_response",
	/** number of rows affected by the mutation */
	affected_rows:number,
	/** data from the rows affected by the mutation */
	returning:users[]
}

/** input type for inserting object relation for remote table "users" */
export type users_obj_rel_insert_input = {
		data:users_insert_input,
	/** upsert condition */
	on_conflict?:users_on_conflict
}

/** on_conflict condition type for table "users" */
export type users_on_conflict = {
		constraint:users_constraint,
	update_columns:users_update_column[],
	where?:users_bool_exp
}

/** Ordering options when selecting data from "users". */
export type users_order_by = {
		apple_id?:order_by,
	config?:order_by,
	events_aggregate?:events_aggregate_order_by,
	id?:order_by,
	language?:order_by,
	locations_aggregate?:locations_aggregate_order_by,
	name?:order_by,
	timezone?:order_by
}

/** primary key columns input for table: users */
export type users_pk_columns_input = {
		id:number
}

/** prepend existing jsonb value of filtered columns with new jsonb value */
export type users_prepend_input = {
		config?:jsonb
}

export type users_scalar = any

/** select columns of table "users" */
export enum users_select_column {
	apple_id = "apple_id",
	config = "config",
	id = "id",
	language = "language",
	name = "name",
	timezone = "timezone"
}

/** input type for updating data in table "users" */
export type users_set_input = {
		apple_id?:string,
	config?:jsonb,
	id?:number,
	language?:string,
	name?:string,
	timezone?:string
}

/** aggregate stddev on columns */
export type users_stddev_fields = {
	__typename?: "users_stddev_fields",
	id?:number
}

/** aggregate stddev_pop on columns */
export type users_stddev_pop_fields = {
	__typename?: "users_stddev_pop_fields",
	id?:number
}

/** aggregate stddev_samp on columns */
export type users_stddev_samp_fields = {
	__typename?: "users_stddev_samp_fields",
	id?:number
}

/** Streaming cursor of the table "users" */
export type users_stream_cursor_input = {
		/** Stream column input with initial value */
	initial_value:users_stream_cursor_value_input,
	/** cursor ordering */
	ordering?:cursor_ordering
}

/** Initial value of the column from where the streaming should start */
export type users_stream_cursor_value_input = {
		apple_id?:string,
	config?:jsonb,
	id?:number,
	language?:string,
	name?:string,
	timezone?:string
}

/** aggregate sum on columns */
export type users_sum_fields = {
	__typename?: "users_sum_fields",
	id?:number
}

/** update columns of table "users" */
export enum users_update_column {
	apple_id = "apple_id",
	config = "config",
	id = "id",
	language = "language",
	name = "name",
	timezone = "timezone"
}

export type users_updates = {
		/** append existing jsonb value of filtered columns with new jsonb value */
	_append?:users_append_input,
	/** delete the field or element with specified path (for JSON arrays, negative integers count from the end) */
	_delete_at_path?:users_delete_at_path_input,
	/** delete the array element with specified index (negative integers count from
the end). throws an error if top level container is not an array */
	_delete_elem?:users_delete_elem_input,
	/** delete key/value pair or string element. key/value pairs are matched based on their key value */
	_delete_key?:users_delete_key_input,
	/** increments the numeric columns with given value of the filtered values */
	_inc?:users_inc_input,
	/** prepend existing jsonb value of filtered columns with new jsonb value */
	_prepend?:users_prepend_input,
	/** sets the columns of the filtered rows to the given values */
	_set?:users_set_input,
	/** filter the rows which have to be updated */
	where:users_bool_exp
}

/** aggregate var_pop on columns */
export type users_var_pop_fields = {
	__typename?: "users_var_pop_fields",
	id?:number
}

/** aggregate var_samp on columns */
export type users_var_samp_fields = {
	__typename?: "users_var_samp_fields",
	id?:number
}

/** aggregate variance on columns */
export type users_variance_fields = {
	__typename?: "users_variance_fields",
	id?:number
}

export type vector = any

/** Boolean expression to compare columns of type "vector". All fields are combined with logical 'AND'. */
export type vector_comparison_exp = {
		_eq?:vector,
	_gt?:vector,
	_gte?:vector,
	_in?:vector[],
	_is_null?:boolean,
	_lt?:vector,
	_lte?:vector,
	_neq?:vector,
	_nin?:vector[]
}

export const AllTypesProps: Record<string,any> = {
	cached:{
		ttl:{
			60:{
				type:"IntValue",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		refresh:{
			false:{
				type:"BooleanValue",
				array:false,
				arrayRequired:false,
				required:false
			}
		}
	},
	associations:{
		metadata:{
			path:{
				type:"String",
				array:false,
				arrayRequired:false,
				required:false
			}
		}
	},
	associations_aggregate_fields:{
		count:{
			columns:{
				type:"associations_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			distinct:{
				type:"Boolean",
				array:false,
				arrayRequired:false,
				required:false
			}
		}
	},
	associations_aggregate_order_by:{
		avg:{
			type:"associations_avg_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		count:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		max:{
			type:"associations_max_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		min:{
			type:"associations_min_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		stddev:{
			type:"associations_stddev_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		stddev_pop:{
			type:"associations_stddev_pop_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		stddev_samp:{
			type:"associations_stddev_samp_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		sum:{
			type:"associations_sum_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		var_pop:{
			type:"associations_var_pop_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		var_samp:{
			type:"associations_var_samp_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		variance:{
			type:"associations_variance_order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	associations_append_input:{
		metadata:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	associations_avg_order_by:{
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_one_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_two_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	associations_bool_exp:{
		_and:{
			type:"associations_bool_exp",
			array:true,
			arrayRequired:false,
			required:true
		},
		_not:{
			type:"associations_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		_or:{
			type:"associations_bool_exp",
			array:true,
			arrayRequired:false,
			required:true
		},
		id:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		metadata:{
			type:"jsonb_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_one_id:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_one_table:{
			type:"String_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_two_id:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_two_table:{
			type:"String_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	associations_constraint: "enum",
	associations_delete_at_path_input:{
		metadata:{
			type:"String",
			array:true,
			arrayRequired:false,
			required:true
		}
	},
	associations_delete_elem_input:{
		metadata:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	associations_delete_key_input:{
		metadata:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	associations_inc_input:{
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_one_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_two_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	associations_insert_input:{
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		metadata:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_one_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_one_table:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_two_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_two_table:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	associations_max_order_by:{
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_one_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_one_table:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_two_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_two_table:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	associations_min_order_by:{
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_one_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_one_table:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_two_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_two_table:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	associations_on_conflict:{
		constraint:{
			type:"associations_constraint",
			array:false,
			arrayRequired:false,
			required:true
		},
		update_columns:{
			type:"associations_update_column",
			array:true,
			arrayRequired:true,
			required:true
		},
		where:{
			type:"associations_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	associations_order_by:{
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		metadata:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_one_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_one_table:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_two_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_two_table:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	associations_pk_columns_input:{
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	associations_prepend_input:{
		metadata:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	associations_select_column: "enum",
	associations_set_input:{
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		metadata:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_one_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_one_table:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_two_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_two_table:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	associations_stddev_order_by:{
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_one_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_two_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	associations_stddev_pop_order_by:{
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_one_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_two_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	associations_stddev_samp_order_by:{
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_one_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_two_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	associations_stream_cursor_input:{
		initial_value:{
			type:"associations_stream_cursor_value_input",
			array:false,
			arrayRequired:false,
			required:true
		},
		ordering:{
			type:"cursor_ordering",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	associations_stream_cursor_value_input:{
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		metadata:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_one_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_one_table:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_two_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_two_table:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	associations_sum_order_by:{
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_one_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_two_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	associations_update_column: "enum",
	associations_updates:{
		_append:{
			type:"associations_append_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_delete_at_path:{
			type:"associations_delete_at_path_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_delete_elem:{
			type:"associations_delete_elem_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_delete_key:{
			type:"associations_delete_key_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_inc:{
			type:"associations_inc_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_prepend:{
			type:"associations_prepend_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_set:{
			type:"associations_set_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		where:{
			type:"associations_bool_exp",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	associations_var_pop_order_by:{
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_one_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_two_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	associations_var_samp_order_by:{
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_one_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_two_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	associations_variance_order_by:{
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_one_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_two_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	Boolean_comparison_exp:{
		_eq:{
			type:"Boolean",
			array:false,
			arrayRequired:false,
			required:false
		},
		_gt:{
			type:"Boolean",
			array:false,
			arrayRequired:false,
			required:false
		},
		_gte:{
			type:"Boolean",
			array:false,
			arrayRequired:false,
			required:false
		},
		_in:{
			type:"Boolean",
			array:true,
			arrayRequired:false,
			required:true
		},
		_is_null:{
			type:"Boolean",
			array:false,
			arrayRequired:false,
			required:false
		},
		_lt:{
			type:"Boolean",
			array:false,
			arrayRequired:false,
			required:false
		},
		_lte:{
			type:"Boolean",
			array:false,
			arrayRequired:false,
			required:false
		},
		_neq:{
			type:"Boolean",
			array:false,
			arrayRequired:false,
			required:false
		},
		_nin:{
			type:"Boolean",
			array:true,
			arrayRequired:false,
			required:true
		}
	},
	closest_user_location_args:{
		radius:{
			type:"float8",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_point:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_row:{
			type:"users_scalar",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	closest_user_location_users_args:{
		radius:{
			type:"float8",
			array:false,
			arrayRequired:false,
			required:false
		},
		ref_point:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	cursor_ordering: "enum",
	event_tag_aggregate_bool_exp:{
		count:{
			type:"event_tag_aggregate_bool_exp_count",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_tag_aggregate_bool_exp_count:{
		arguments:{
			type:"event_tag_select_column",
			array:true,
			arrayRequired:false,
			required:true
		},
		distinct:{
			type:"Boolean",
			array:false,
			arrayRequired:false,
			required:false
		},
		filter:{
			type:"event_tag_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		predicate:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	event_tag_aggregate_fields:{
		count:{
			columns:{
				type:"event_tag_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			distinct:{
				type:"Boolean",
				array:false,
				arrayRequired:false,
				required:false
			}
		}
	},
	event_tag_aggregate_order_by:{
		avg:{
			type:"event_tag_avg_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		count:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		max:{
			type:"event_tag_max_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		min:{
			type:"event_tag_min_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		stddev:{
			type:"event_tag_stddev_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		stddev_pop:{
			type:"event_tag_stddev_pop_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		stddev_samp:{
			type:"event_tag_stddev_samp_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		sum:{
			type:"event_tag_sum_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		var_pop:{
			type:"event_tag_var_pop_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		var_samp:{
			type:"event_tag_var_samp_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		variance:{
			type:"event_tag_variance_order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_tag_arr_rel_insert_input:{
		data:{
			type:"event_tag_insert_input",
			array:true,
			arrayRequired:true,
			required:true
		},
		on_conflict:{
			type:"event_tag_on_conflict",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_tag_avg_order_by:{
		event_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_tag_bool_exp:{
		_and:{
			type:"event_tag_bool_exp",
			array:true,
			arrayRequired:false,
			required:true
		},
		_not:{
			type:"event_tag_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		_or:{
			type:"event_tag_bool_exp",
			array:true,
			arrayRequired:false,
			required:true
		},
		event:{
			type:"events_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		event_id:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		tag_name:{
			type:"String_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_tag_constraint: "enum",
	event_tag_inc_input:{
		event_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_tag_insert_input:{
		event:{
			type:"events_obj_rel_insert_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		event_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		tag_name:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_tag_max_order_by:{
		event_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		tag_name:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_tag_min_order_by:{
		event_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		tag_name:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_tag_on_conflict:{
		constraint:{
			type:"event_tag_constraint",
			array:false,
			arrayRequired:false,
			required:true
		},
		update_columns:{
			type:"event_tag_update_column",
			array:true,
			arrayRequired:true,
			required:true
		},
		where:{
			type:"event_tag_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_tag_order_by:{
		event:{
			type:"events_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		event_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		tag_name:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_tag_pk_columns_input:{
		event_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:true
		},
		tag_name:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	event_tag_select_column: "enum",
	event_tag_set_input:{
		event_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		tag_name:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_tag_stddev_order_by:{
		event_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_tag_stddev_pop_order_by:{
		event_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_tag_stddev_samp_order_by:{
		event_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_tag_stream_cursor_input:{
		initial_value:{
			type:"event_tag_stream_cursor_value_input",
			array:false,
			arrayRequired:false,
			required:true
		},
		ordering:{
			type:"cursor_ordering",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_tag_stream_cursor_value_input:{
		event_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		tag_name:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_tag_sum_order_by:{
		event_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_tag_update_column: "enum",
	event_tag_updates:{
		_inc:{
			type:"event_tag_inc_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_set:{
			type:"event_tag_set_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		where:{
			type:"event_tag_bool_exp",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	event_tag_var_pop_order_by:{
		event_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_tag_var_samp_order_by:{
		event_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_tag_variance_order_by:{
		event_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_types:{
		children:{
			distinct_on:{
				type:"event_types_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"event_types_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"event_types_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		children_aggregate:{
			distinct_on:{
				type:"event_types_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"event_types_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"event_types_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		metadata:{
			path:{
				type:"String",
				array:false,
				arrayRequired:false,
				required:false
			}
		}
	},
	event_types_aggregate_bool_exp:{
		count:{
			type:"event_types_aggregate_bool_exp_count",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_types_aggregate_bool_exp_count:{
		arguments:{
			type:"event_types_select_column",
			array:true,
			arrayRequired:false,
			required:true
		},
		distinct:{
			type:"Boolean",
			array:false,
			arrayRequired:false,
			required:false
		},
		filter:{
			type:"event_types_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		predicate:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	event_types_aggregate_fields:{
		count:{
			columns:{
				type:"event_types_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			distinct:{
				type:"Boolean",
				array:false,
				arrayRequired:false,
				required:false
			}
		}
	},
	event_types_aggregate_order_by:{
		count:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		max:{
			type:"event_types_max_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		min:{
			type:"event_types_min_order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_types_append_input:{
		metadata:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_types_arr_rel_insert_input:{
		data:{
			type:"event_types_insert_input",
			array:true,
			arrayRequired:true,
			required:true
		},
		on_conflict:{
			type:"event_types_on_conflict",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_types_bool_exp:{
		_and:{
			type:"event_types_bool_exp",
			array:true,
			arrayRequired:false,
			required:true
		},
		_not:{
			type:"event_types_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		_or:{
			type:"event_types_bool_exp",
			array:true,
			arrayRequired:false,
			required:true
		},
		children:{
			type:"event_types_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		children_aggregate:{
			type:"event_types_aggregate_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		embedding:{
			type:"vector_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		metadata:{
			type:"jsonb_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"String_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent:{
			type:"String_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent_tree:{
			type:"String_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_types_constraint: "enum",
	event_types_delete_at_path_input:{
		metadata:{
			type:"String",
			array:true,
			arrayRequired:false,
			required:true
		}
	},
	event_types_delete_elem_input:{
		metadata:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_types_delete_key_input:{
		metadata:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_types_insert_input:{
		children:{
			type:"event_types_arr_rel_insert_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		embedding:{
			type:"vector",
			array:false,
			arrayRequired:false,
			required:false
		},
		metadata:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_types_max_order_by:{
		name:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_types_min_order_by:{
		name:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_types_obj_rel_insert_input:{
		data:{
			type:"event_types_insert_input",
			array:false,
			arrayRequired:false,
			required:true
		},
		on_conflict:{
			type:"event_types_on_conflict",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_types_on_conflict:{
		constraint:{
			type:"event_types_constraint",
			array:false,
			arrayRequired:false,
			required:true
		},
		update_columns:{
			type:"event_types_update_column",
			array:true,
			arrayRequired:true,
			required:true
		},
		where:{
			type:"event_types_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_types_order_by:{
		children_aggregate:{
			type:"event_types_aggregate_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		embedding:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		metadata:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent_tree:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_types_pk_columns_input:{
		name:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	event_types_prepend_input:{
		metadata:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_types_select_column: "enum",
	event_types_set_input:{
		embedding:{
			type:"vector",
			array:false,
			arrayRequired:false,
			required:false
		},
		metadata:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_types_stream_cursor_input:{
		initial_value:{
			type:"event_types_stream_cursor_value_input",
			array:false,
			arrayRequired:false,
			required:true
		},
		ordering:{
			type:"cursor_ordering",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_types_stream_cursor_value_input:{
		embedding:{
			type:"vector",
			array:false,
			arrayRequired:false,
			required:false
		},
		metadata:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	event_types_update_column: "enum",
	event_types_updates:{
		_append:{
			type:"event_types_append_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_delete_at_path:{
			type:"event_types_delete_at_path_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_delete_elem:{
			type:"event_types_delete_elem_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_delete_key:{
			type:"event_types_delete_key_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_prepend:{
			type:"event_types_prepend_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_set:{
			type:"event_types_set_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		where:{
			type:"event_types_bool_exp",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	events:{
		associations:{
			distinct_on:{
				type:"associations_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"associations_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"associations_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		children:{
			distinct_on:{
				type:"events_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"events_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"events_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		children_aggregate:{
			distinct_on:{
				type:"events_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"events_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"events_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		event_tags:{
			distinct_on:{
				type:"event_tag_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"event_tag_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"event_tag_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		event_tags_aggregate:{
			distinct_on:{
				type:"event_tag_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"event_tag_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"event_tag_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		logs:{
			path:{
				type:"String",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		metadata:{
			path:{
				type:"String",
				array:false,
				arrayRequired:false,
				required:false
			}
		}
	},
	events_aggregate_bool_exp:{
		count:{
			type:"events_aggregate_bool_exp_count",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	events_aggregate_bool_exp_count:{
		arguments:{
			type:"events_select_column",
			array:true,
			arrayRequired:false,
			required:true
		},
		distinct:{
			type:"Boolean",
			array:false,
			arrayRequired:false,
			required:false
		},
		filter:{
			type:"events_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		predicate:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	events_aggregate_fields:{
		count:{
			columns:{
				type:"events_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			distinct:{
				type:"Boolean",
				array:false,
				arrayRequired:false,
				required:false
			}
		}
	},
	events_aggregate_order_by:{
		avg:{
			type:"events_avg_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		count:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		max:{
			type:"events_max_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		min:{
			type:"events_min_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		stddev:{
			type:"events_stddev_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		stddev_pop:{
			type:"events_stddev_pop_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		stddev_samp:{
			type:"events_stddev_samp_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		sum:{
			type:"events_sum_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		var_pop:{
			type:"events_var_pop_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		var_samp:{
			type:"events_var_samp_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		variance:{
			type:"events_variance_order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	events_append_input:{
		logs:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		metadata:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	events_arr_rel_insert_input:{
		data:{
			type:"events_insert_input",
			array:true,
			arrayRequired:true,
			required:true
		},
		on_conflict:{
			type:"events_on_conflict",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	events_avg_order_by:{
		cost_money:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		cost_time:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		goal_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		interaction_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	events_bool_exp:{
		_and:{
			type:"events_bool_exp",
			array:true,
			arrayRequired:false,
			required:true
		},
		_not:{
			type:"events_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		_or:{
			type:"events_bool_exp",
			array:true,
			arrayRequired:false,
			required:true
		},
		associations:{
			type:"associations_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		children:{
			type:"events_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		children_aggregate:{
			type:"events_aggregate_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		computed_cost_time:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		cost_money:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		cost_time:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		end_time:{
			type:"timestamp_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		event_tags:{
			type:"event_tag_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		event_tags_aggregate:{
			type:"event_tag_aggregate_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		event_type:{
			type:"String_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		event_type_object:{
			type:"event_types_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		goal_id:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		interaction:{
			type:"interactions_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		interaction_id:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		logs:{
			type:"jsonb_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		metadata:{
			type:"jsonb_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent:{
			type:"events_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent_id:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		start_time:{
			type:"timestamp_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		status:{
			type:"String_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		user:{
			type:"users_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	events_constraint: "enum",
	events_delete_at_path_input:{
		logs:{
			type:"String",
			array:true,
			arrayRequired:false,
			required:true
		},
		metadata:{
			type:"String",
			array:true,
			arrayRequired:false,
			required:true
		}
	},
	events_delete_elem_input:{
		logs:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		metadata:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	events_delete_key_input:{
		logs:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		metadata:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	events_inc_input:{
		cost_money:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		cost_time:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		goal_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		interaction_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	events_insert_input:{
		children:{
			type:"events_arr_rel_insert_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		cost_money:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		cost_time:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		end_time:{
			type:"timestamp",
			array:false,
			arrayRequired:false,
			required:false
		},
		event_tags:{
			type:"event_tag_arr_rel_insert_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		event_type:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		event_type_object:{
			type:"event_types_obj_rel_insert_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		goal_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		interaction:{
			type:"interactions_obj_rel_insert_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		interaction_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		logs:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		metadata:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent:{
			type:"events_obj_rel_insert_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		start_time:{
			type:"timestamp",
			array:false,
			arrayRequired:false,
			required:false
		},
		status:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		user:{
			type:"users_obj_rel_insert_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	events_max_order_by:{
		cost_money:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		cost_time:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		end_time:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		event_type:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		goal_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		interaction_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		start_time:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		status:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	events_min_order_by:{
		cost_money:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		cost_time:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		end_time:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		event_type:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		goal_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		interaction_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		start_time:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		status:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	events_obj_rel_insert_input:{
		data:{
			type:"events_insert_input",
			array:false,
			arrayRequired:false,
			required:true
		},
		on_conflict:{
			type:"events_on_conflict",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	events_on_conflict:{
		constraint:{
			type:"events_constraint",
			array:false,
			arrayRequired:false,
			required:true
		},
		update_columns:{
			type:"events_update_column",
			array:true,
			arrayRequired:true,
			required:true
		},
		where:{
			type:"events_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	events_order_by:{
		associations_aggregate:{
			type:"associations_aggregate_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		children_aggregate:{
			type:"events_aggregate_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		computed_cost_time:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		cost_money:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		cost_time:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		end_time:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		event_tags_aggregate:{
			type:"event_tag_aggregate_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		event_type:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		event_type_object:{
			type:"event_types_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		goal_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		interaction:{
			type:"interactions_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		interaction_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		logs:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		metadata:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent:{
			type:"events_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		start_time:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		status:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user:{
			type:"users_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	events_pk_columns_input:{
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	events_prepend_input:{
		logs:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		metadata:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	events_select_column: "enum",
	events_set_input:{
		cost_money:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		cost_time:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		end_time:{
			type:"timestamp",
			array:false,
			arrayRequired:false,
			required:false
		},
		event_type:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		goal_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		interaction_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		logs:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		metadata:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		start_time:{
			type:"timestamp",
			array:false,
			arrayRequired:false,
			required:false
		},
		status:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	events_stddev_order_by:{
		cost_money:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		cost_time:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		goal_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		interaction_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	events_stddev_pop_order_by:{
		cost_money:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		cost_time:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		goal_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		interaction_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	events_stddev_samp_order_by:{
		cost_money:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		cost_time:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		goal_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		interaction_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	events_stream_cursor_input:{
		initial_value:{
			type:"events_stream_cursor_value_input",
			array:false,
			arrayRequired:false,
			required:true
		},
		ordering:{
			type:"cursor_ordering",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	events_stream_cursor_value_input:{
		cost_money:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		cost_time:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		end_time:{
			type:"timestamp",
			array:false,
			arrayRequired:false,
			required:false
		},
		event_type:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		goal_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		interaction_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		logs:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		metadata:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		start_time:{
			type:"timestamp",
			array:false,
			arrayRequired:false,
			required:false
		},
		status:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	events_sum_order_by:{
		cost_money:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		cost_time:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		goal_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		interaction_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	events_update_column: "enum",
	events_updates:{
		_append:{
			type:"events_append_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_delete_at_path:{
			type:"events_delete_at_path_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_delete_elem:{
			type:"events_delete_elem_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_delete_key:{
			type:"events_delete_key_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_inc:{
			type:"events_inc_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_prepend:{
			type:"events_prepend_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_set:{
			type:"events_set_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		where:{
			type:"events_bool_exp",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	events_var_pop_order_by:{
		cost_money:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		cost_time:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		goal_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		interaction_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	events_var_samp_order_by:{
		cost_money:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		cost_time:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		goal_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		interaction_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	events_variance_order_by:{
		cost_money:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		cost_time:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		goal_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		interaction_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		parent_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	fetch_associations_args:{
		from_row_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		from_row_type:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	float8: "String",
	float8_comparison_exp:{
		_eq:{
			type:"float8",
			array:false,
			arrayRequired:false,
			required:false
		},
		_gt:{
			type:"float8",
			array:false,
			arrayRequired:false,
			required:false
		},
		_gte:{
			type:"float8",
			array:false,
			arrayRequired:false,
			required:false
		},
		_in:{
			type:"float8",
			array:true,
			arrayRequired:false,
			required:true
		},
		_is_null:{
			type:"Boolean",
			array:false,
			arrayRequired:false,
			required:false
		},
		_lt:{
			type:"float8",
			array:false,
			arrayRequired:false,
			required:false
		},
		_lte:{
			type:"float8",
			array:false,
			arrayRequired:false,
			required:false
		},
		_neq:{
			type:"float8",
			array:false,
			arrayRequired:false,
			required:false
		},
		_nin:{
			type:"float8",
			array:true,
			arrayRequired:false,
			required:true
		}
	},
	geography: "String",
	geography_cast_exp:{
		geometry:{
			type:"geometry_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	geography_comparison_exp:{
		_cast:{
			type:"geography_cast_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		_eq:{
			type:"geography",
			array:false,
			arrayRequired:false,
			required:false
		},
		_gt:{
			type:"geography",
			array:false,
			arrayRequired:false,
			required:false
		},
		_gte:{
			type:"geography",
			array:false,
			arrayRequired:false,
			required:false
		},
		_in:{
			type:"geography",
			array:true,
			arrayRequired:false,
			required:true
		},
		_is_null:{
			type:"Boolean",
			array:false,
			arrayRequired:false,
			required:false
		},
		_lt:{
			type:"geography",
			array:false,
			arrayRequired:false,
			required:false
		},
		_lte:{
			type:"geography",
			array:false,
			arrayRequired:false,
			required:false
		},
		_neq:{
			type:"geography",
			array:false,
			arrayRequired:false,
			required:false
		},
		_nin:{
			type:"geography",
			array:true,
			arrayRequired:false,
			required:true
		},
		_st_d_within:{
			type:"st_d_within_geography_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_st_intersects:{
			type:"geography",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	geometry: "String",
	geometry_cast_exp:{
		geography:{
			type:"geography_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	geometry_comparison_exp:{
		_cast:{
			type:"geometry_cast_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		_eq:{
			type:"geometry",
			array:false,
			arrayRequired:false,
			required:false
		},
		_gt:{
			type:"geometry",
			array:false,
			arrayRequired:false,
			required:false
		},
		_gte:{
			type:"geometry",
			array:false,
			arrayRequired:false,
			required:false
		},
		_in:{
			type:"geometry",
			array:true,
			arrayRequired:false,
			required:true
		},
		_is_null:{
			type:"Boolean",
			array:false,
			arrayRequired:false,
			required:false
		},
		_lt:{
			type:"geometry",
			array:false,
			arrayRequired:false,
			required:false
		},
		_lte:{
			type:"geometry",
			array:false,
			arrayRequired:false,
			required:false
		},
		_neq:{
			type:"geometry",
			array:false,
			arrayRequired:false,
			required:false
		},
		_nin:{
			type:"geometry",
			array:true,
			arrayRequired:false,
			required:true
		},
		_st_3d_d_within:{
			type:"st_d_within_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_st_3d_intersects:{
			type:"geometry",
			array:false,
			arrayRequired:false,
			required:false
		},
		_st_contains:{
			type:"geometry",
			array:false,
			arrayRequired:false,
			required:false
		},
		_st_crosses:{
			type:"geometry",
			array:false,
			arrayRequired:false,
			required:false
		},
		_st_d_within:{
			type:"st_d_within_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_st_equals:{
			type:"geometry",
			array:false,
			arrayRequired:false,
			required:false
		},
		_st_intersects:{
			type:"geometry",
			array:false,
			arrayRequired:false,
			required:false
		},
		_st_overlaps:{
			type:"geometry",
			array:false,
			arrayRequired:false,
			required:false
		},
		_st_touches:{
			type:"geometry",
			array:false,
			arrayRequired:false,
			required:false
		},
		_st_within:{
			type:"geometry",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	goals:{
		frequency:{
			path:{
				type:"String",
				array:false,
				arrayRequired:false,
				required:false
			}
		}
	},
	goals_aggregate_fields:{
		count:{
			columns:{
				type:"goals_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			distinct:{
				type:"Boolean",
				array:false,
				arrayRequired:false,
				required:false
			}
		}
	},
	goals_append_input:{
		frequency:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	goals_bool_exp:{
		_and:{
			type:"goals_bool_exp",
			array:true,
			arrayRequired:false,
			required:true
		},
		_not:{
			type:"goals_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		_or:{
			type:"goals_bool_exp",
			array:true,
			arrayRequired:false,
			required:true
		},
		created:{
			type:"timestamptz_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		frequency:{
			type:"jsonb_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"String_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		nl_description:{
			type:"String_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		status:{
			type:"String_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		todo:{
			type:"todos_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		user:{
			type:"users_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	goals_constraint: "enum",
	goals_delete_at_path_input:{
		frequency:{
			type:"String",
			array:true,
			arrayRequired:false,
			required:true
		}
	},
	goals_delete_elem_input:{
		frequency:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	goals_delete_key_input:{
		frequency:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	goals_inc_input:{
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	goals_insert_input:{
		created:{
			type:"timestamptz",
			array:false,
			arrayRequired:false,
			required:false
		},
		frequency:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		nl_description:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		status:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		todo:{
			type:"todos_obj_rel_insert_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		user:{
			type:"users_obj_rel_insert_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	goals_obj_rel_insert_input:{
		data:{
			type:"goals_insert_input",
			array:false,
			arrayRequired:false,
			required:true
		},
		on_conflict:{
			type:"goals_on_conflict",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	goals_on_conflict:{
		constraint:{
			type:"goals_constraint",
			array:false,
			arrayRequired:false,
			required:true
		},
		update_columns:{
			type:"goals_update_column",
			array:true,
			arrayRequired:true,
			required:true
		},
		where:{
			type:"goals_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	goals_order_by:{
		created:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		frequency:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		nl_description:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		status:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		todo:{
			type:"todos_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user:{
			type:"users_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	goals_pk_columns_input:{
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	goals_prepend_input:{
		frequency:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	goals_select_column: "enum",
	goals_set_input:{
		created:{
			type:"timestamptz",
			array:false,
			arrayRequired:false,
			required:false
		},
		frequency:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		nl_description:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		status:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	goals_stream_cursor_input:{
		initial_value:{
			type:"goals_stream_cursor_value_input",
			array:false,
			arrayRequired:false,
			required:true
		},
		ordering:{
			type:"cursor_ordering",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	goals_stream_cursor_value_input:{
		created:{
			type:"timestamptz",
			array:false,
			arrayRequired:false,
			required:false
		},
		frequency:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		nl_description:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		status:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	goals_update_column: "enum",
	goals_updates:{
		_append:{
			type:"goals_append_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_delete_at_path:{
			type:"goals_delete_at_path_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_delete_elem:{
			type:"goals_delete_elem_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_delete_key:{
			type:"goals_delete_key_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_inc:{
			type:"goals_inc_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_prepend:{
			type:"goals_prepend_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_set:{
			type:"goals_set_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		where:{
			type:"goals_bool_exp",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	Int_comparison_exp:{
		_eq:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		_gt:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		_gte:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		_in:{
			type:"Int",
			array:true,
			arrayRequired:false,
			required:true
		},
		_is_null:{
			type:"Boolean",
			array:false,
			arrayRequired:false,
			required:false
		},
		_lt:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		_lte:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		_neq:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		_nin:{
			type:"Int",
			array:true,
			arrayRequired:false,
			required:true
		}
	},
	interactions:{
		debug:{
			path:{
				type:"String",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		events:{
			distinct_on:{
				type:"events_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"events_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"events_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		events_aggregate:{
			distinct_on:{
				type:"events_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"events_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"events_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		}
	},
	interactions_aggregate_fields:{
		count:{
			columns:{
				type:"interactions_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			distinct:{
				type:"Boolean",
				array:false,
				arrayRequired:false,
				required:false
			}
		}
	},
	interactions_append_input:{
		debug:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	interactions_bool_exp:{
		_and:{
			type:"interactions_bool_exp",
			array:true,
			arrayRequired:false,
			required:true
		},
		_not:{
			type:"interactions_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		_or:{
			type:"interactions_bool_exp",
			array:true,
			arrayRequired:false,
			required:true
		},
		content:{
			type:"String_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		content_type:{
			type:"String_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		debug:{
			type:"jsonb_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		embedding:{
			type:"vector_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		events:{
			type:"events_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		events_aggregate:{
			type:"events_aggregate_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		match_score:{
			type:"float8_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		timestamp:{
			type:"timestamptz_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	interactions_constraint: "enum",
	interactions_delete_at_path_input:{
		debug:{
			type:"String",
			array:true,
			arrayRequired:false,
			required:true
		}
	},
	interactions_delete_elem_input:{
		debug:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	interactions_delete_key_input:{
		debug:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	interactions_inc_input:{
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		match_score:{
			type:"float8",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	interactions_insert_input:{
		content:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		content_type:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		debug:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		embedding:{
			type:"vector",
			array:false,
			arrayRequired:false,
			required:false
		},
		events:{
			type:"events_arr_rel_insert_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		match_score:{
			type:"float8",
			array:false,
			arrayRequired:false,
			required:false
		},
		timestamp:{
			type:"timestamptz",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	interactions_obj_rel_insert_input:{
		data:{
			type:"interactions_insert_input",
			array:false,
			arrayRequired:false,
			required:true
		},
		on_conflict:{
			type:"interactions_on_conflict",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	interactions_on_conflict:{
		constraint:{
			type:"interactions_constraint",
			array:false,
			arrayRequired:false,
			required:true
		},
		update_columns:{
			type:"interactions_update_column",
			array:true,
			arrayRequired:true,
			required:true
		},
		where:{
			type:"interactions_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	interactions_order_by:{
		content:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		content_type:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		debug:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		embedding:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		events_aggregate:{
			type:"events_aggregate_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		match_score:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		timestamp:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	interactions_pk_columns_input:{
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	interactions_prepend_input:{
		debug:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	interactions_select_column: "enum",
	interactions_set_input:{
		content:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		content_type:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		debug:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		embedding:{
			type:"vector",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		match_score:{
			type:"float8",
			array:false,
			arrayRequired:false,
			required:false
		},
		timestamp:{
			type:"timestamptz",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	interactions_stream_cursor_input:{
		initial_value:{
			type:"interactions_stream_cursor_value_input",
			array:false,
			arrayRequired:false,
			required:true
		},
		ordering:{
			type:"cursor_ordering",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	interactions_stream_cursor_value_input:{
		content:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		content_type:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		debug:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		embedding:{
			type:"vector",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		match_score:{
			type:"float8",
			array:false,
			arrayRequired:false,
			required:false
		},
		timestamp:{
			type:"timestamptz",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	interactions_update_column: "enum",
	interactions_updates:{
		_append:{
			type:"interactions_append_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_delete_at_path:{
			type:"interactions_delete_at_path_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_delete_elem:{
			type:"interactions_delete_elem_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_delete_key:{
			type:"interactions_delete_key_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_inc:{
			type:"interactions_inc_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_prepend:{
			type:"interactions_prepend_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_set:{
			type:"interactions_set_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		where:{
			type:"interactions_bool_exp",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	jsonb: "String",
	jsonb_cast_exp:{
		String:{
			type:"String_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	jsonb_comparison_exp:{
		_cast:{
			type:"jsonb_cast_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		_contained_in:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		_contains:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		_eq:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		_gt:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		_gte:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		_has_key:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		_has_keys_all:{
			type:"String",
			array:true,
			arrayRequired:false,
			required:true
		},
		_has_keys_any:{
			type:"String",
			array:true,
			arrayRequired:false,
			required:true
		},
		_in:{
			type:"jsonb",
			array:true,
			arrayRequired:false,
			required:true
		},
		_is_null:{
			type:"Boolean",
			array:false,
			arrayRequired:false,
			required:false
		},
		_lt:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		_lte:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		_neq:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		_nin:{
			type:"jsonb",
			array:true,
			arrayRequired:false,
			required:true
		}
	},
	locations_aggregate_bool_exp:{
		count:{
			type:"locations_aggregate_bool_exp_count",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	locations_aggregate_bool_exp_count:{
		arguments:{
			type:"locations_select_column",
			array:true,
			arrayRequired:false,
			required:true
		},
		distinct:{
			type:"Boolean",
			array:false,
			arrayRequired:false,
			required:false
		},
		filter:{
			type:"locations_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		predicate:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	locations_aggregate_fields:{
		count:{
			columns:{
				type:"locations_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			distinct:{
				type:"Boolean",
				array:false,
				arrayRequired:false,
				required:false
			}
		}
	},
	locations_aggregate_order_by:{
		avg:{
			type:"locations_avg_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		count:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		max:{
			type:"locations_max_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		min:{
			type:"locations_min_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		stddev:{
			type:"locations_stddev_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		stddev_pop:{
			type:"locations_stddev_pop_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		stddev_samp:{
			type:"locations_stddev_samp_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		sum:{
			type:"locations_sum_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		var_pop:{
			type:"locations_var_pop_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		var_samp:{
			type:"locations_var_samp_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		variance:{
			type:"locations_variance_order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	locations_arr_rel_insert_input:{
		data:{
			type:"locations_insert_input",
			array:true,
			arrayRequired:true,
			required:true
		},
		on_conflict:{
			type:"locations_on_conflict",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	locations_avg_order_by:{
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	locations_bool_exp:{
		_and:{
			type:"locations_bool_exp",
			array:true,
			arrayRequired:false,
			required:true
		},
		_not:{
			type:"locations_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		_or:{
			type:"locations_bool_exp",
			array:true,
			arrayRequired:false,
			required:true
		},
		id:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		location:{
			type:"geography_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"String_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	locations_constraint: "enum",
	locations_inc_input:{
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	locations_insert_input:{
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		location:{
			type:"geography",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	locations_max_order_by:{
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	locations_min_order_by:{
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	locations_on_conflict:{
		constraint:{
			type:"locations_constraint",
			array:false,
			arrayRequired:false,
			required:true
		},
		update_columns:{
			type:"locations_update_column",
			array:true,
			arrayRequired:true,
			required:true
		},
		where:{
			type:"locations_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	locations_order_by:{
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		location:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	locations_pk_columns_input:{
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	locations_select_column: "enum",
	locations_set_input:{
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		location:{
			type:"geography",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	locations_stddev_order_by:{
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	locations_stddev_pop_order_by:{
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	locations_stddev_samp_order_by:{
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	locations_stream_cursor_input:{
		initial_value:{
			type:"locations_stream_cursor_value_input",
			array:false,
			arrayRequired:false,
			required:true
		},
		ordering:{
			type:"cursor_ordering",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	locations_stream_cursor_value_input:{
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		location:{
			type:"geography",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	locations_sum_order_by:{
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	locations_update_column: "enum",
	locations_updates:{
		_inc:{
			type:"locations_inc_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_set:{
			type:"locations_set_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		where:{
			type:"locations_bool_exp",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	locations_var_pop_order_by:{
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	locations_var_samp_order_by:{
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	locations_variance_order_by:{
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	match_interactions_args:{
		match_threshold:{
			type:"float8",
			array:false,
			arrayRequired:false,
			required:false
		},
		query_embedding:{
			type:"vector",
			array:false,
			arrayRequired:false,
			required:false
		},
		target_user_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	mutation_root:{
		delete_associations:{
			where:{
				type:"associations_bool_exp",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		delete_associations_by_pk:{
			id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		delete_event_tag:{
			where:{
				type:"event_tag_bool_exp",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		delete_event_tag_by_pk:{
			event_id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			},
			tag_name:{
				type:"String",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		delete_event_types:{
			where:{
				type:"event_types_bool_exp",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		delete_event_types_by_pk:{
			name:{
				type:"String",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		delete_events:{
			where:{
				type:"events_bool_exp",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		delete_events_by_pk:{
			id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		delete_goals:{
			where:{
				type:"goals_bool_exp",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		delete_goals_by_pk:{
			id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		delete_interactions:{
			where:{
				type:"interactions_bool_exp",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		delete_interactions_by_pk:{
			id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		delete_locations:{
			where:{
				type:"locations_bool_exp",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		delete_locations_by_pk:{
			id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		delete_object_types:{
			where:{
				type:"object_types_bool_exp",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		delete_object_types_by_pk:{
			id:{
				type:"String",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		delete_objects:{
			where:{
				type:"objects_bool_exp",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		delete_objects_by_pk:{
			id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		delete_todos:{
			where:{
				type:"todos_bool_exp",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		delete_todos_by_pk:{
			id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		delete_users:{
			where:{
				type:"users_bool_exp",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		delete_users_by_pk:{
			id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		insert_associations:{
			objects:{
				type:"associations_insert_input",
				array:true,
				arrayRequired:true,
				required:true
			},
			on_conflict:{
				type:"associations_on_conflict",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		insert_associations_one:{
			object:{
				type:"associations_insert_input",
				array:false,
				arrayRequired:false,
				required:true
			},
			on_conflict:{
				type:"associations_on_conflict",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		insert_event_tag:{
			objects:{
				type:"event_tag_insert_input",
				array:true,
				arrayRequired:true,
				required:true
			},
			on_conflict:{
				type:"event_tag_on_conflict",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		insert_event_tag_one:{
			object:{
				type:"event_tag_insert_input",
				array:false,
				arrayRequired:false,
				required:true
			},
			on_conflict:{
				type:"event_tag_on_conflict",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		insert_event_types:{
			objects:{
				type:"event_types_insert_input",
				array:true,
				arrayRequired:true,
				required:true
			},
			on_conflict:{
				type:"event_types_on_conflict",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		insert_event_types_one:{
			object:{
				type:"event_types_insert_input",
				array:false,
				arrayRequired:false,
				required:true
			},
			on_conflict:{
				type:"event_types_on_conflict",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		insert_events:{
			objects:{
				type:"events_insert_input",
				array:true,
				arrayRequired:true,
				required:true
			},
			on_conflict:{
				type:"events_on_conflict",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		insert_events_one:{
			object:{
				type:"events_insert_input",
				array:false,
				arrayRequired:false,
				required:true
			},
			on_conflict:{
				type:"events_on_conflict",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		insert_goals:{
			objects:{
				type:"goals_insert_input",
				array:true,
				arrayRequired:true,
				required:true
			},
			on_conflict:{
				type:"goals_on_conflict",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		insert_goals_one:{
			object:{
				type:"goals_insert_input",
				array:false,
				arrayRequired:false,
				required:true
			},
			on_conflict:{
				type:"goals_on_conflict",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		insert_interactions:{
			objects:{
				type:"interactions_insert_input",
				array:true,
				arrayRequired:true,
				required:true
			},
			on_conflict:{
				type:"interactions_on_conflict",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		insert_interactions_one:{
			object:{
				type:"interactions_insert_input",
				array:false,
				arrayRequired:false,
				required:true
			},
			on_conflict:{
				type:"interactions_on_conflict",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		insert_locations:{
			objects:{
				type:"locations_insert_input",
				array:true,
				arrayRequired:true,
				required:true
			},
			on_conflict:{
				type:"locations_on_conflict",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		insert_locations_one:{
			object:{
				type:"locations_insert_input",
				array:false,
				arrayRequired:false,
				required:true
			},
			on_conflict:{
				type:"locations_on_conflict",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		insert_object_types:{
			objects:{
				type:"object_types_insert_input",
				array:true,
				arrayRequired:true,
				required:true
			},
			on_conflict:{
				type:"object_types_on_conflict",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		insert_object_types_one:{
			object:{
				type:"object_types_insert_input",
				array:false,
				arrayRequired:false,
				required:true
			},
			on_conflict:{
				type:"object_types_on_conflict",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		insert_objects:{
			objects:{
				type:"objects_insert_input",
				array:true,
				arrayRequired:true,
				required:true
			},
			on_conflict:{
				type:"objects_on_conflict",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		insert_objects_one:{
			object:{
				type:"objects_insert_input",
				array:false,
				arrayRequired:false,
				required:true
			},
			on_conflict:{
				type:"objects_on_conflict",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		insert_todos:{
			objects:{
				type:"todos_insert_input",
				array:true,
				arrayRequired:true,
				required:true
			},
			on_conflict:{
				type:"todos_on_conflict",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		insert_todos_one:{
			object:{
				type:"todos_insert_input",
				array:false,
				arrayRequired:false,
				required:true
			},
			on_conflict:{
				type:"todos_on_conflict",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		insert_users:{
			objects:{
				type:"users_insert_input",
				array:true,
				arrayRequired:true,
				required:true
			},
			on_conflict:{
				type:"users_on_conflict",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		insert_users_one:{
			object:{
				type:"users_insert_input",
				array:false,
				arrayRequired:false,
				required:true
			},
			on_conflict:{
				type:"users_on_conflict",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		update_associations:{
			_append:{
				type:"associations_append_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_at_path:{
				type:"associations_delete_at_path_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_elem:{
				type:"associations_delete_elem_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_key:{
				type:"associations_delete_key_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_inc:{
				type:"associations_inc_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_prepend:{
				type:"associations_prepend_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_set:{
				type:"associations_set_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			where:{
				type:"associations_bool_exp",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		update_associations_by_pk:{
			_append:{
				type:"associations_append_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_at_path:{
				type:"associations_delete_at_path_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_elem:{
				type:"associations_delete_elem_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_key:{
				type:"associations_delete_key_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_inc:{
				type:"associations_inc_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_prepend:{
				type:"associations_prepend_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_set:{
				type:"associations_set_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			pk_columns:{
				type:"associations_pk_columns_input",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		update_associations_many:{
			updates:{
				type:"associations_updates",
				array:true,
				arrayRequired:true,
				required:true
			}
		},
		update_event_tag:{
			_inc:{
				type:"event_tag_inc_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_set:{
				type:"event_tag_set_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			where:{
				type:"event_tag_bool_exp",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		update_event_tag_by_pk:{
			_inc:{
				type:"event_tag_inc_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_set:{
				type:"event_tag_set_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			pk_columns:{
				type:"event_tag_pk_columns_input",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		update_event_tag_many:{
			updates:{
				type:"event_tag_updates",
				array:true,
				arrayRequired:true,
				required:true
			}
		},
		update_event_types:{
			_append:{
				type:"event_types_append_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_at_path:{
				type:"event_types_delete_at_path_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_elem:{
				type:"event_types_delete_elem_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_key:{
				type:"event_types_delete_key_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_prepend:{
				type:"event_types_prepend_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_set:{
				type:"event_types_set_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			where:{
				type:"event_types_bool_exp",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		update_event_types_by_pk:{
			_append:{
				type:"event_types_append_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_at_path:{
				type:"event_types_delete_at_path_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_elem:{
				type:"event_types_delete_elem_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_key:{
				type:"event_types_delete_key_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_prepend:{
				type:"event_types_prepend_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_set:{
				type:"event_types_set_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			pk_columns:{
				type:"event_types_pk_columns_input",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		update_event_types_many:{
			updates:{
				type:"event_types_updates",
				array:true,
				arrayRequired:true,
				required:true
			}
		},
		update_events:{
			_append:{
				type:"events_append_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_at_path:{
				type:"events_delete_at_path_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_elem:{
				type:"events_delete_elem_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_key:{
				type:"events_delete_key_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_inc:{
				type:"events_inc_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_prepend:{
				type:"events_prepend_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_set:{
				type:"events_set_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			where:{
				type:"events_bool_exp",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		update_events_by_pk:{
			_append:{
				type:"events_append_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_at_path:{
				type:"events_delete_at_path_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_elem:{
				type:"events_delete_elem_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_key:{
				type:"events_delete_key_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_inc:{
				type:"events_inc_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_prepend:{
				type:"events_prepend_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_set:{
				type:"events_set_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			pk_columns:{
				type:"events_pk_columns_input",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		update_events_many:{
			updates:{
				type:"events_updates",
				array:true,
				arrayRequired:true,
				required:true
			}
		},
		update_goals:{
			_append:{
				type:"goals_append_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_at_path:{
				type:"goals_delete_at_path_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_elem:{
				type:"goals_delete_elem_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_key:{
				type:"goals_delete_key_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_inc:{
				type:"goals_inc_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_prepend:{
				type:"goals_prepend_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_set:{
				type:"goals_set_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			where:{
				type:"goals_bool_exp",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		update_goals_by_pk:{
			_append:{
				type:"goals_append_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_at_path:{
				type:"goals_delete_at_path_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_elem:{
				type:"goals_delete_elem_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_key:{
				type:"goals_delete_key_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_inc:{
				type:"goals_inc_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_prepend:{
				type:"goals_prepend_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_set:{
				type:"goals_set_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			pk_columns:{
				type:"goals_pk_columns_input",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		update_goals_many:{
			updates:{
				type:"goals_updates",
				array:true,
				arrayRequired:true,
				required:true
			}
		},
		update_interactions:{
			_append:{
				type:"interactions_append_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_at_path:{
				type:"interactions_delete_at_path_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_elem:{
				type:"interactions_delete_elem_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_key:{
				type:"interactions_delete_key_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_inc:{
				type:"interactions_inc_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_prepend:{
				type:"interactions_prepend_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_set:{
				type:"interactions_set_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			where:{
				type:"interactions_bool_exp",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		update_interactions_by_pk:{
			_append:{
				type:"interactions_append_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_at_path:{
				type:"interactions_delete_at_path_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_elem:{
				type:"interactions_delete_elem_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_key:{
				type:"interactions_delete_key_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_inc:{
				type:"interactions_inc_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_prepend:{
				type:"interactions_prepend_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_set:{
				type:"interactions_set_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			pk_columns:{
				type:"interactions_pk_columns_input",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		update_interactions_many:{
			updates:{
				type:"interactions_updates",
				array:true,
				arrayRequired:true,
				required:true
			}
		},
		update_locations:{
			_inc:{
				type:"locations_inc_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_set:{
				type:"locations_set_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			where:{
				type:"locations_bool_exp",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		update_locations_by_pk:{
			_inc:{
				type:"locations_inc_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_set:{
				type:"locations_set_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			pk_columns:{
				type:"locations_pk_columns_input",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		update_locations_many:{
			updates:{
				type:"locations_updates",
				array:true,
				arrayRequired:true,
				required:true
			}
		},
		update_object_types:{
			_append:{
				type:"object_types_append_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_at_path:{
				type:"object_types_delete_at_path_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_elem:{
				type:"object_types_delete_elem_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_key:{
				type:"object_types_delete_key_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_prepend:{
				type:"object_types_prepend_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_set:{
				type:"object_types_set_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			where:{
				type:"object_types_bool_exp",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		update_object_types_by_pk:{
			_append:{
				type:"object_types_append_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_at_path:{
				type:"object_types_delete_at_path_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_elem:{
				type:"object_types_delete_elem_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_key:{
				type:"object_types_delete_key_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_prepend:{
				type:"object_types_prepend_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_set:{
				type:"object_types_set_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			pk_columns:{
				type:"object_types_pk_columns_input",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		update_object_types_many:{
			updates:{
				type:"object_types_updates",
				array:true,
				arrayRequired:true,
				required:true
			}
		},
		update_objects:{
			_inc:{
				type:"objects_inc_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_set:{
				type:"objects_set_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			where:{
				type:"objects_bool_exp",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		update_objects_by_pk:{
			_inc:{
				type:"objects_inc_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_set:{
				type:"objects_set_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			pk_columns:{
				type:"objects_pk_columns_input",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		update_objects_many:{
			updates:{
				type:"objects_updates",
				array:true,
				arrayRequired:true,
				required:true
			}
		},
		update_todos:{
			_inc:{
				type:"todos_inc_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_set:{
				type:"todos_set_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			where:{
				type:"todos_bool_exp",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		update_todos_by_pk:{
			_inc:{
				type:"todos_inc_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_set:{
				type:"todos_set_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			pk_columns:{
				type:"todos_pk_columns_input",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		update_todos_many:{
			updates:{
				type:"todos_updates",
				array:true,
				arrayRequired:true,
				required:true
			}
		},
		update_users:{
			_append:{
				type:"users_append_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_at_path:{
				type:"users_delete_at_path_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_elem:{
				type:"users_delete_elem_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_key:{
				type:"users_delete_key_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_inc:{
				type:"users_inc_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_prepend:{
				type:"users_prepend_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_set:{
				type:"users_set_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			where:{
				type:"users_bool_exp",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		update_users_by_pk:{
			_append:{
				type:"users_append_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_at_path:{
				type:"users_delete_at_path_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_elem:{
				type:"users_delete_elem_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_delete_key:{
				type:"users_delete_key_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_inc:{
				type:"users_inc_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_prepend:{
				type:"users_prepend_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			_set:{
				type:"users_set_input",
				array:false,
				arrayRequired:false,
				required:false
			},
			pk_columns:{
				type:"users_pk_columns_input",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		update_users_many:{
			updates:{
				type:"users_updates",
				array:true,
				arrayRequired:true,
				required:true
			}
		}
	},
	object_types:{
		metadata:{
			path:{
				type:"String",
				array:false,
				arrayRequired:false,
				required:false
			}
		}
	},
	object_types_aggregate_fields:{
		count:{
			columns:{
				type:"object_types_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			distinct:{
				type:"Boolean",
				array:false,
				arrayRequired:false,
				required:false
			}
		}
	},
	object_types_append_input:{
		metadata:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	object_types_bool_exp:{
		_and:{
			type:"object_types_bool_exp",
			array:true,
			arrayRequired:false,
			required:true
		},
		_not:{
			type:"object_types_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		_or:{
			type:"object_types_bool_exp",
			array:true,
			arrayRequired:false,
			required:true
		},
		id:{
			type:"String_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		metadata:{
			type:"jsonb_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	object_types_constraint: "enum",
	object_types_delete_at_path_input:{
		metadata:{
			type:"String",
			array:true,
			arrayRequired:false,
			required:true
		}
	},
	object_types_delete_elem_input:{
		metadata:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	object_types_delete_key_input:{
		metadata:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	object_types_insert_input:{
		id:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		metadata:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	object_types_on_conflict:{
		constraint:{
			type:"object_types_constraint",
			array:false,
			arrayRequired:false,
			required:true
		},
		update_columns:{
			type:"object_types_update_column",
			array:true,
			arrayRequired:true,
			required:true
		},
		where:{
			type:"object_types_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	object_types_order_by:{
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		metadata:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	object_types_pk_columns_input:{
		id:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	object_types_prepend_input:{
		metadata:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	object_types_select_column: "enum",
	object_types_set_input:{
		id:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		metadata:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	object_types_stream_cursor_input:{
		initial_value:{
			type:"object_types_stream_cursor_value_input",
			array:false,
			arrayRequired:false,
			required:true
		},
		ordering:{
			type:"cursor_ordering",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	object_types_stream_cursor_value_input:{
		id:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		metadata:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	object_types_update_column: "enum",
	object_types_updates:{
		_append:{
			type:"object_types_append_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_delete_at_path:{
			type:"object_types_delete_at_path_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_delete_elem:{
			type:"object_types_delete_elem_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_delete_key:{
			type:"object_types_delete_key_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_prepend:{
			type:"object_types_prepend_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_set:{
			type:"object_types_set_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		where:{
			type:"object_types_bool_exp",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	objects_aggregate_fields:{
		count:{
			columns:{
				type:"objects_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			distinct:{
				type:"Boolean",
				array:false,
				arrayRequired:false,
				required:false
			}
		}
	},
	objects_bool_exp:{
		_and:{
			type:"objects_bool_exp",
			array:true,
			arrayRequired:false,
			required:true
		},
		_not:{
			type:"objects_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		_or:{
			type:"objects_bool_exp",
			array:true,
			arrayRequired:false,
			required:true
		},
		id:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"String_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		object_type:{
			type:"String_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	objects_constraint: "enum",
	objects_inc_input:{
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	objects_insert_input:{
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		object_type:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	objects_on_conflict:{
		constraint:{
			type:"objects_constraint",
			array:false,
			arrayRequired:false,
			required:true
		},
		update_columns:{
			type:"objects_update_column",
			array:true,
			arrayRequired:true,
			required:true
		},
		where:{
			type:"objects_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	objects_order_by:{
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		object_type:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	objects_pk_columns_input:{
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	objects_select_column: "enum",
	objects_set_input:{
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		object_type:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	objects_stream_cursor_input:{
		initial_value:{
			type:"objects_stream_cursor_value_input",
			array:false,
			arrayRequired:false,
			required:true
		},
		ordering:{
			type:"cursor_ordering",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	objects_stream_cursor_value_input:{
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		object_type:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	objects_update_column: "enum",
	objects_updates:{
		_inc:{
			type:"objects_inc_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_set:{
			type:"objects_set_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		where:{
			type:"objects_bool_exp",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	order_by: "enum",
	query_root:{
		associations:{
			distinct_on:{
				type:"associations_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"associations_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"associations_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		associations_aggregate:{
			distinct_on:{
				type:"associations_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"associations_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"associations_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		associations_by_pk:{
			id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		closest_user_location:{
			args:{
				type:"closest_user_location_args",
				array:false,
				arrayRequired:false,
				required:true
			},
			distinct_on:{
				type:"locations_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"locations_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"locations_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		closest_user_location_aggregate:{
			args:{
				type:"closest_user_location_args",
				array:false,
				arrayRequired:false,
				required:true
			},
			distinct_on:{
				type:"locations_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"locations_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"locations_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		event_tag:{
			distinct_on:{
				type:"event_tag_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"event_tag_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"event_tag_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		event_tag_aggregate:{
			distinct_on:{
				type:"event_tag_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"event_tag_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"event_tag_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		event_tag_by_pk:{
			event_id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			},
			tag_name:{
				type:"String",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		event_types:{
			distinct_on:{
				type:"event_types_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"event_types_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"event_types_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		event_types_aggregate:{
			distinct_on:{
				type:"event_types_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"event_types_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"event_types_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		event_types_by_pk:{
			name:{
				type:"String",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		events:{
			distinct_on:{
				type:"events_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"events_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"events_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		events_aggregate:{
			distinct_on:{
				type:"events_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"events_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"events_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		events_by_pk:{
			id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		fetch_associations:{
			args:{
				type:"fetch_associations_args",
				array:false,
				arrayRequired:false,
				required:true
			},
			distinct_on:{
				type:"associations_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"associations_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"associations_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		fetch_associations_aggregate:{
			args:{
				type:"fetch_associations_args",
				array:false,
				arrayRequired:false,
				required:true
			},
			distinct_on:{
				type:"associations_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"associations_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"associations_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		goals:{
			distinct_on:{
				type:"goals_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"goals_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"goals_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		goals_aggregate:{
			distinct_on:{
				type:"goals_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"goals_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"goals_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		goals_by_pk:{
			id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		interactions:{
			distinct_on:{
				type:"interactions_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"interactions_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"interactions_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		interactions_aggregate:{
			distinct_on:{
				type:"interactions_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"interactions_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"interactions_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		interactions_by_pk:{
			id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		locations:{
			distinct_on:{
				type:"locations_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"locations_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"locations_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		locations_aggregate:{
			distinct_on:{
				type:"locations_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"locations_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"locations_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		locations_by_pk:{
			id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		match_interactions:{
			args:{
				type:"match_interactions_args",
				array:false,
				arrayRequired:false,
				required:true
			},
			distinct_on:{
				type:"interactions_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"interactions_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"interactions_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		match_interactions_aggregate:{
			args:{
				type:"match_interactions_args",
				array:false,
				arrayRequired:false,
				required:true
			},
			distinct_on:{
				type:"interactions_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"interactions_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"interactions_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		object_types:{
			distinct_on:{
				type:"object_types_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"object_types_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"object_types_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		object_types_aggregate:{
			distinct_on:{
				type:"object_types_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"object_types_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"object_types_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		object_types_by_pk:{
			id:{
				type:"String",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		objects:{
			distinct_on:{
				type:"objects_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"objects_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"objects_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		objects_aggregate:{
			distinct_on:{
				type:"objects_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"objects_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"objects_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		objects_by_pk:{
			id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		todos:{
			distinct_on:{
				type:"todos_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"todos_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"todos_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		todos_aggregate:{
			distinct_on:{
				type:"todos_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"todos_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"todos_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		todos_by_pk:{
			id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		users:{
			distinct_on:{
				type:"users_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"users_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"users_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		users_aggregate:{
			distinct_on:{
				type:"users_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"users_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"users_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		users_by_pk:{
			id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			}
		}
	},
	st_d_within_geography_input:{
		distance:{
			type:"Float",
			array:false,
			arrayRequired:false,
			required:true
		},
		from:{
			type:"geography",
			array:false,
			arrayRequired:false,
			required:true
		},
		use_spheroid:{
			type:"Boolean",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	st_d_within_input:{
		distance:{
			type:"Float",
			array:false,
			arrayRequired:false,
			required:true
		},
		from:{
			type:"geometry",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	String_comparison_exp:{
		_eq:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		_gt:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		_gte:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		_ilike:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		_in:{
			type:"String",
			array:true,
			arrayRequired:false,
			required:true
		},
		_iregex:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		_is_null:{
			type:"Boolean",
			array:false,
			arrayRequired:false,
			required:false
		},
		_like:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		_lt:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		_lte:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		_neq:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		_nilike:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		_nin:{
			type:"String",
			array:true,
			arrayRequired:false,
			required:true
		},
		_niregex:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		_nlike:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		_nregex:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		_nsimilar:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		_regex:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		_similar:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	subscription_root:{
		associations:{
			distinct_on:{
				type:"associations_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"associations_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"associations_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		associations_aggregate:{
			distinct_on:{
				type:"associations_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"associations_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"associations_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		associations_by_pk:{
			id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		associations_stream:{
			batch_size:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			},
			cursor:{
				type:"associations_stream_cursor_input",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"associations_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		closest_user_location:{
			args:{
				type:"closest_user_location_args",
				array:false,
				arrayRequired:false,
				required:true
			},
			distinct_on:{
				type:"locations_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"locations_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"locations_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		closest_user_location_aggregate:{
			args:{
				type:"closest_user_location_args",
				array:false,
				arrayRequired:false,
				required:true
			},
			distinct_on:{
				type:"locations_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"locations_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"locations_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		event_tag:{
			distinct_on:{
				type:"event_tag_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"event_tag_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"event_tag_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		event_tag_aggregate:{
			distinct_on:{
				type:"event_tag_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"event_tag_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"event_tag_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		event_tag_by_pk:{
			event_id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			},
			tag_name:{
				type:"String",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		event_tag_stream:{
			batch_size:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			},
			cursor:{
				type:"event_tag_stream_cursor_input",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"event_tag_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		event_types:{
			distinct_on:{
				type:"event_types_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"event_types_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"event_types_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		event_types_aggregate:{
			distinct_on:{
				type:"event_types_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"event_types_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"event_types_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		event_types_by_pk:{
			name:{
				type:"String",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		event_types_stream:{
			batch_size:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			},
			cursor:{
				type:"event_types_stream_cursor_input",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"event_types_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		events:{
			distinct_on:{
				type:"events_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"events_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"events_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		events_aggregate:{
			distinct_on:{
				type:"events_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"events_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"events_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		events_by_pk:{
			id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		events_stream:{
			batch_size:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			},
			cursor:{
				type:"events_stream_cursor_input",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"events_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		fetch_associations:{
			args:{
				type:"fetch_associations_args",
				array:false,
				arrayRequired:false,
				required:true
			},
			distinct_on:{
				type:"associations_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"associations_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"associations_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		fetch_associations_aggregate:{
			args:{
				type:"fetch_associations_args",
				array:false,
				arrayRequired:false,
				required:true
			},
			distinct_on:{
				type:"associations_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"associations_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"associations_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		goals:{
			distinct_on:{
				type:"goals_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"goals_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"goals_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		goals_aggregate:{
			distinct_on:{
				type:"goals_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"goals_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"goals_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		goals_by_pk:{
			id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		goals_stream:{
			batch_size:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			},
			cursor:{
				type:"goals_stream_cursor_input",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"goals_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		interactions:{
			distinct_on:{
				type:"interactions_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"interactions_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"interactions_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		interactions_aggregate:{
			distinct_on:{
				type:"interactions_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"interactions_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"interactions_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		interactions_by_pk:{
			id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		interactions_stream:{
			batch_size:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			},
			cursor:{
				type:"interactions_stream_cursor_input",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"interactions_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		locations:{
			distinct_on:{
				type:"locations_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"locations_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"locations_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		locations_aggregate:{
			distinct_on:{
				type:"locations_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"locations_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"locations_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		locations_by_pk:{
			id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		locations_stream:{
			batch_size:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			},
			cursor:{
				type:"locations_stream_cursor_input",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"locations_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		match_interactions:{
			args:{
				type:"match_interactions_args",
				array:false,
				arrayRequired:false,
				required:true
			},
			distinct_on:{
				type:"interactions_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"interactions_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"interactions_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		match_interactions_aggregate:{
			args:{
				type:"match_interactions_args",
				array:false,
				arrayRequired:false,
				required:true
			},
			distinct_on:{
				type:"interactions_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"interactions_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"interactions_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		object_types:{
			distinct_on:{
				type:"object_types_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"object_types_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"object_types_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		object_types_aggregate:{
			distinct_on:{
				type:"object_types_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"object_types_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"object_types_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		object_types_by_pk:{
			id:{
				type:"String",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		object_types_stream:{
			batch_size:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			},
			cursor:{
				type:"object_types_stream_cursor_input",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"object_types_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		objects:{
			distinct_on:{
				type:"objects_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"objects_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"objects_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		objects_aggregate:{
			distinct_on:{
				type:"objects_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"objects_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"objects_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		objects_by_pk:{
			id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		objects_stream:{
			batch_size:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			},
			cursor:{
				type:"objects_stream_cursor_input",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"objects_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		todos:{
			distinct_on:{
				type:"todos_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"todos_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"todos_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		todos_aggregate:{
			distinct_on:{
				type:"todos_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"todos_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"todos_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		todos_by_pk:{
			id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		todos_stream:{
			batch_size:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			},
			cursor:{
				type:"todos_stream_cursor_input",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"todos_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		users:{
			distinct_on:{
				type:"users_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"users_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"users_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		users_aggregate:{
			distinct_on:{
				type:"users_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"users_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"users_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		users_by_pk:{
			id:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			}
		},
		users_stream:{
			batch_size:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:true
			},
			cursor:{
				type:"users_stream_cursor_input",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"users_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		}
	},
	timestamp: "String",
	timestamp_comparison_exp:{
		_eq:{
			type:"timestamp",
			array:false,
			arrayRequired:false,
			required:false
		},
		_gt:{
			type:"timestamp",
			array:false,
			arrayRequired:false,
			required:false
		},
		_gte:{
			type:"timestamp",
			array:false,
			arrayRequired:false,
			required:false
		},
		_in:{
			type:"timestamp",
			array:true,
			arrayRequired:false,
			required:true
		},
		_is_null:{
			type:"Boolean",
			array:false,
			arrayRequired:false,
			required:false
		},
		_lt:{
			type:"timestamp",
			array:false,
			arrayRequired:false,
			required:false
		},
		_lte:{
			type:"timestamp",
			array:false,
			arrayRequired:false,
			required:false
		},
		_neq:{
			type:"timestamp",
			array:false,
			arrayRequired:false,
			required:false
		},
		_nin:{
			type:"timestamp",
			array:true,
			arrayRequired:false,
			required:true
		}
	},
	timestamptz: "String",
	timestamptz_comparison_exp:{
		_eq:{
			type:"timestamptz",
			array:false,
			arrayRequired:false,
			required:false
		},
		_gt:{
			type:"timestamptz",
			array:false,
			arrayRequired:false,
			required:false
		},
		_gte:{
			type:"timestamptz",
			array:false,
			arrayRequired:false,
			required:false
		},
		_in:{
			type:"timestamptz",
			array:true,
			arrayRequired:false,
			required:true
		},
		_is_null:{
			type:"Boolean",
			array:false,
			arrayRequired:false,
			required:false
		},
		_lt:{
			type:"timestamptz",
			array:false,
			arrayRequired:false,
			required:false
		},
		_lte:{
			type:"timestamptz",
			array:false,
			arrayRequired:false,
			required:false
		},
		_neq:{
			type:"timestamptz",
			array:false,
			arrayRequired:false,
			required:false
		},
		_nin:{
			type:"timestamptz",
			array:true,
			arrayRequired:false,
			required:true
		}
	},
	todos_aggregate_fields:{
		count:{
			columns:{
				type:"todos_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			distinct:{
				type:"Boolean",
				array:false,
				arrayRequired:false,
				required:false
			}
		}
	},
	todos_bool_exp:{
		_and:{
			type:"todos_bool_exp",
			array:true,
			arrayRequired:false,
			required:true
		},
		_not:{
			type:"todos_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		_or:{
			type:"todos_bool_exp",
			array:true,
			arrayRequired:false,
			required:true
		},
		current_count:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		done_as_expected:{
			type:"Boolean_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		due:{
			type:"timestamptz_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		goal:{
			type:"goals_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		goal_id:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"String_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		status:{
			type:"String_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		updated:{
			type:"timestamptz_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		user:{
			type:"users_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	todos_constraint: "enum",
	todos_inc_input:{
		current_count:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		goal_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	todos_insert_input:{
		current_count:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		done_as_expected:{
			type:"Boolean",
			array:false,
			arrayRequired:false,
			required:false
		},
		due:{
			type:"timestamptz",
			array:false,
			arrayRequired:false,
			required:false
		},
		goal:{
			type:"goals_obj_rel_insert_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		goal_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		status:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		updated:{
			type:"timestamptz",
			array:false,
			arrayRequired:false,
			required:false
		},
		user:{
			type:"users_obj_rel_insert_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	todos_obj_rel_insert_input:{
		data:{
			type:"todos_insert_input",
			array:false,
			arrayRequired:false,
			required:true
		},
		on_conflict:{
			type:"todos_on_conflict",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	todos_on_conflict:{
		constraint:{
			type:"todos_constraint",
			array:false,
			arrayRequired:false,
			required:true
		},
		update_columns:{
			type:"todos_update_column",
			array:true,
			arrayRequired:true,
			required:true
		},
		where:{
			type:"todos_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	todos_order_by:{
		current_count:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		done_as_expected:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		due:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		goal:{
			type:"goals_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		goal_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		status:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		updated:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user:{
			type:"users_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	todos_pk_columns_input:{
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	todos_select_column: "enum",
	todos_set_input:{
		current_count:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		done_as_expected:{
			type:"Boolean",
			array:false,
			arrayRequired:false,
			required:false
		},
		due:{
			type:"timestamptz",
			array:false,
			arrayRequired:false,
			required:false
		},
		goal_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		status:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		updated:{
			type:"timestamptz",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	todos_stream_cursor_input:{
		initial_value:{
			type:"todos_stream_cursor_value_input",
			array:false,
			arrayRequired:false,
			required:true
		},
		ordering:{
			type:"cursor_ordering",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	todos_stream_cursor_value_input:{
		current_count:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		done_as_expected:{
			type:"Boolean",
			array:false,
			arrayRequired:false,
			required:false
		},
		due:{
			type:"timestamptz",
			array:false,
			arrayRequired:false,
			required:false
		},
		goal_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		status:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		updated:{
			type:"timestamptz",
			array:false,
			arrayRequired:false,
			required:false
		},
		user_id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	todos_update_column: "enum",
	todos_updates:{
		_inc:{
			type:"todos_inc_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_set:{
			type:"todos_set_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		where:{
			type:"todos_bool_exp",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	users:{
		closest_user_location:{
			args:{
				type:"closest_user_location_users_args",
				array:false,
				arrayRequired:false,
				required:true
			},
			distinct_on:{
				type:"locations_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"locations_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"locations_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		config:{
			path:{
				type:"String",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		events:{
			distinct_on:{
				type:"events_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"events_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"events_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		events_aggregate:{
			distinct_on:{
				type:"events_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"events_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"events_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		locations:{
			distinct_on:{
				type:"locations_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"locations_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"locations_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		},
		locations_aggregate:{
			distinct_on:{
				type:"locations_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			limit:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			offset:{
				type:"Int",
				array:false,
				arrayRequired:false,
				required:false
			},
			order_by:{
				type:"locations_order_by",
				array:true,
				arrayRequired:false,
				required:true
			},
			where:{
				type:"locations_bool_exp",
				array:false,
				arrayRequired:false,
				required:false
			}
		}
	},
	users_aggregate_fields:{
		count:{
			columns:{
				type:"users_select_column",
				array:true,
				arrayRequired:false,
				required:true
			},
			distinct:{
				type:"Boolean",
				array:false,
				arrayRequired:false,
				required:false
			}
		}
	},
	users_append_input:{
		config:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	users_bool_exp:{
		_and:{
			type:"users_bool_exp",
			array:true,
			arrayRequired:false,
			required:true
		},
		_not:{
			type:"users_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		_or:{
			type:"users_bool_exp",
			array:true,
			arrayRequired:false,
			required:true
		},
		apple_id:{
			type:"String_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		config:{
			type:"jsonb_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		events:{
			type:"events_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		events_aggregate:{
			type:"events_aggregate_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"Int_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		language:{
			type:"String_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		locations:{
			type:"locations_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		locations_aggregate:{
			type:"locations_aggregate_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"String_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		},
		timezone:{
			type:"String_comparison_exp",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	users_constraint: "enum",
	users_delete_at_path_input:{
		config:{
			type:"String",
			array:true,
			arrayRequired:false,
			required:true
		}
	},
	users_delete_elem_input:{
		config:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	users_delete_key_input:{
		config:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	users_inc_input:{
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	users_insert_input:{
		apple_id:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		config:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		events:{
			type:"events_arr_rel_insert_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		language:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		locations:{
			type:"locations_arr_rel_insert_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		timezone:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	users_obj_rel_insert_input:{
		data:{
			type:"users_insert_input",
			array:false,
			arrayRequired:false,
			required:true
		},
		on_conflict:{
			type:"users_on_conflict",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	users_on_conflict:{
		constraint:{
			type:"users_constraint",
			array:false,
			arrayRequired:false,
			required:true
		},
		update_columns:{
			type:"users_update_column",
			array:true,
			arrayRequired:true,
			required:true
		},
		where:{
			type:"users_bool_exp",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	users_order_by:{
		apple_id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		config:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		events_aggregate:{
			type:"events_aggregate_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		language:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		locations_aggregate:{
			type:"locations_aggregate_order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		},
		timezone:{
			type:"order_by",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	users_pk_columns_input:{
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	users_prepend_input:{
		config:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	users_scalar: "String",
	users_select_column: "enum",
	users_set_input:{
		apple_id:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		config:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		language:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		timezone:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	users_stream_cursor_input:{
		initial_value:{
			type:"users_stream_cursor_value_input",
			array:false,
			arrayRequired:false,
			required:true
		},
		ordering:{
			type:"cursor_ordering",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	users_stream_cursor_value_input:{
		apple_id:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		config:{
			type:"jsonb",
			array:false,
			arrayRequired:false,
			required:false
		},
		id:{
			type:"Int",
			array:false,
			arrayRequired:false,
			required:false
		},
		language:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		name:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		},
		timezone:{
			type:"String",
			array:false,
			arrayRequired:false,
			required:false
		}
	},
	users_update_column: "enum",
	users_updates:{
		_append:{
			type:"users_append_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_delete_at_path:{
			type:"users_delete_at_path_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_delete_elem:{
			type:"users_delete_elem_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_delete_key:{
			type:"users_delete_key_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_inc:{
			type:"users_inc_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_prepend:{
			type:"users_prepend_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		_set:{
			type:"users_set_input",
			array:false,
			arrayRequired:false,
			required:false
		},
		where:{
			type:"users_bool_exp",
			array:false,
			arrayRequired:false,
			required:true
		}
	},
	vector: "String",
	vector_comparison_exp:{
		_eq:{
			type:"vector",
			array:false,
			arrayRequired:false,
			required:false
		},
		_gt:{
			type:"vector",
			array:false,
			arrayRequired:false,
			required:false
		},
		_gte:{
			type:"vector",
			array:false,
			arrayRequired:false,
			required:false
		},
		_in:{
			type:"vector",
			array:true,
			arrayRequired:false,
			required:true
		},
		_is_null:{
			type:"Boolean",
			array:false,
			arrayRequired:false,
			required:false
		},
		_lt:{
			type:"vector",
			array:false,
			arrayRequired:false,
			required:false
		},
		_lte:{
			type:"vector",
			array:false,
			arrayRequired:false,
			required:false
		},
		_neq:{
			type:"vector",
			array:false,
			arrayRequired:false,
			required:false
		},
		_nin:{
			type:"vector",
			array:true,
			arrayRequired:false,
			required:true
		}
	}
}

export const ReturnTypes: Record<string,any> = {
	associations:{
		id:"Int",
		metadata:"jsonb",
		ref_one_id:"Int",
		ref_one_table:"String",
		ref_two_id:"Int",
		ref_two_table:"String"
	},
	associations_aggregate:{
		aggregate:"associations_aggregate_fields",
		nodes:"associations"
	},
	associations_aggregate_fields:{
		avg:"associations_avg_fields",
		count:"Int",
		max:"associations_max_fields",
		min:"associations_min_fields",
		stddev:"associations_stddev_fields",
		stddev_pop:"associations_stddev_pop_fields",
		stddev_samp:"associations_stddev_samp_fields",
		sum:"associations_sum_fields",
		var_pop:"associations_var_pop_fields",
		var_samp:"associations_var_samp_fields",
		variance:"associations_variance_fields"
	},
	associations_avg_fields:{
		id:"Float",
		ref_one_id:"Float",
		ref_two_id:"Float"
	},
	associations_max_fields:{
		id:"Int",
		ref_one_id:"Int",
		ref_one_table:"String",
		ref_two_id:"Int",
		ref_two_table:"String"
	},
	associations_min_fields:{
		id:"Int",
		ref_one_id:"Int",
		ref_one_table:"String",
		ref_two_id:"Int",
		ref_two_table:"String"
	},
	associations_mutation_response:{
		affected_rows:"Int",
		returning:"associations"
	},
	associations_stddev_fields:{
		id:"Float",
		ref_one_id:"Float",
		ref_two_id:"Float"
	},
	associations_stddev_pop_fields:{
		id:"Float",
		ref_one_id:"Float",
		ref_two_id:"Float"
	},
	associations_stddev_samp_fields:{
		id:"Float",
		ref_one_id:"Float",
		ref_two_id:"Float"
	},
	associations_sum_fields:{
		id:"Int",
		ref_one_id:"Int",
		ref_two_id:"Int"
	},
	associations_var_pop_fields:{
		id:"Float",
		ref_one_id:"Float",
		ref_two_id:"Float"
	},
	associations_var_samp_fields:{
		id:"Float",
		ref_one_id:"Float",
		ref_two_id:"Float"
	},
	associations_variance_fields:{
		id:"Float",
		ref_one_id:"Float",
		ref_two_id:"Float"
	},
	event_tag:{
		event:"events",
		event_id:"Int",
		tag_name:"String"
	},
	event_tag_aggregate:{
		aggregate:"event_tag_aggregate_fields",
		nodes:"event_tag"
	},
	event_tag_aggregate_fields:{
		avg:"event_tag_avg_fields",
		count:"Int",
		max:"event_tag_max_fields",
		min:"event_tag_min_fields",
		stddev:"event_tag_stddev_fields",
		stddev_pop:"event_tag_stddev_pop_fields",
		stddev_samp:"event_tag_stddev_samp_fields",
		sum:"event_tag_sum_fields",
		var_pop:"event_tag_var_pop_fields",
		var_samp:"event_tag_var_samp_fields",
		variance:"event_tag_variance_fields"
	},
	event_tag_avg_fields:{
		event_id:"Float"
	},
	event_tag_max_fields:{
		event_id:"Int",
		tag_name:"String"
	},
	event_tag_min_fields:{
		event_id:"Int",
		tag_name:"String"
	},
	event_tag_mutation_response:{
		affected_rows:"Int",
		returning:"event_tag"
	},
	event_tag_stddev_fields:{
		event_id:"Float"
	},
	event_tag_stddev_pop_fields:{
		event_id:"Float"
	},
	event_tag_stddev_samp_fields:{
		event_id:"Float"
	},
	event_tag_sum_fields:{
		event_id:"Int"
	},
	event_tag_var_pop_fields:{
		event_id:"Float"
	},
	event_tag_var_samp_fields:{
		event_id:"Float"
	},
	event_tag_variance_fields:{
		event_id:"Float"
	},
	event_types:{
		children:"event_types",
		children_aggregate:"event_types_aggregate",
		embedding:"vector",
		metadata:"jsonb",
		name:"String",
		parent:"String",
		parent_tree:"String"
	},
	event_types_aggregate:{
		aggregate:"event_types_aggregate_fields",
		nodes:"event_types"
	},
	event_types_aggregate_fields:{
		count:"Int",
		max:"event_types_max_fields",
		min:"event_types_min_fields"
	},
	event_types_max_fields:{
		name:"String",
		parent:"String",
		parent_tree:"String"
	},
	event_types_min_fields:{
		name:"String",
		parent:"String",
		parent_tree:"String"
	},
	event_types_mutation_response:{
		affected_rows:"Int",
		returning:"event_types"
	},
	events:{
		associations:"associations",
		children:"events",
		children_aggregate:"events_aggregate",
		computed_cost_time:"Int",
		cost_money:"Int",
		cost_time:"Int",
		end_time:"timestamp",
		event_tags:"event_tag",
		event_tags_aggregate:"event_tag_aggregate",
		event_type:"String",
		event_type_object:"event_types",
		goal_id:"Int",
		id:"Int",
		interaction:"interactions",
		interaction_id:"Int",
		logs:"jsonb",
		metadata:"jsonb",
		parent:"events",
		parent_id:"Int",
		start_time:"timestamp",
		status:"String",
		user:"users",
		user_id:"Int"
	},
	events_aggregate:{
		aggregate:"events_aggregate_fields",
		nodes:"events"
	},
	events_aggregate_fields:{
		avg:"events_avg_fields",
		count:"Int",
		max:"events_max_fields",
		min:"events_min_fields",
		stddev:"events_stddev_fields",
		stddev_pop:"events_stddev_pop_fields",
		stddev_samp:"events_stddev_samp_fields",
		sum:"events_sum_fields",
		var_pop:"events_var_pop_fields",
		var_samp:"events_var_samp_fields",
		variance:"events_variance_fields"
	},
	events_avg_fields:{
		computed_cost_time:"Int",
		cost_money:"Float",
		cost_time:"Float",
		goal_id:"Float",
		id:"Float",
		interaction_id:"Float",
		parent_id:"Float",
		user_id:"Float"
	},
	events_max_fields:{
		computed_cost_time:"Int",
		cost_money:"Int",
		cost_time:"Int",
		end_time:"timestamp",
		event_type:"String",
		goal_id:"Int",
		id:"Int",
		interaction_id:"Int",
		parent_id:"Int",
		start_time:"timestamp",
		status:"String",
		user_id:"Int"
	},
	events_min_fields:{
		computed_cost_time:"Int",
		cost_money:"Int",
		cost_time:"Int",
		end_time:"timestamp",
		event_type:"String",
		goal_id:"Int",
		id:"Int",
		interaction_id:"Int",
		parent_id:"Int",
		start_time:"timestamp",
		status:"String",
		user_id:"Int"
	},
	events_mutation_response:{
		affected_rows:"Int",
		returning:"events"
	},
	events_stddev_fields:{
		computed_cost_time:"Int",
		cost_money:"Float",
		cost_time:"Float",
		goal_id:"Float",
		id:"Float",
		interaction_id:"Float",
		parent_id:"Float",
		user_id:"Float"
	},
	events_stddev_pop_fields:{
		computed_cost_time:"Int",
		cost_money:"Float",
		cost_time:"Float",
		goal_id:"Float",
		id:"Float",
		interaction_id:"Float",
		parent_id:"Float",
		user_id:"Float"
	},
	events_stddev_samp_fields:{
		computed_cost_time:"Int",
		cost_money:"Float",
		cost_time:"Float",
		goal_id:"Float",
		id:"Float",
		interaction_id:"Float",
		parent_id:"Float",
		user_id:"Float"
	},
	events_sum_fields:{
		computed_cost_time:"Int",
		cost_money:"Int",
		cost_time:"Int",
		goal_id:"Int",
		id:"Int",
		interaction_id:"Int",
		parent_id:"Int",
		user_id:"Int"
	},
	events_var_pop_fields:{
		computed_cost_time:"Int",
		cost_money:"Float",
		cost_time:"Float",
		goal_id:"Float",
		id:"Float",
		interaction_id:"Float",
		parent_id:"Float",
		user_id:"Float"
	},
	events_var_samp_fields:{
		computed_cost_time:"Int",
		cost_money:"Float",
		cost_time:"Float",
		goal_id:"Float",
		id:"Float",
		interaction_id:"Float",
		parent_id:"Float",
		user_id:"Float"
	},
	events_variance_fields:{
		computed_cost_time:"Int",
		cost_money:"Float",
		cost_time:"Float",
		goal_id:"Float",
		id:"Float",
		interaction_id:"Float",
		parent_id:"Float",
		user_id:"Float"
	},
	goals:{
		created:"timestamptz",
		frequency:"jsonb",
		id:"Int",
		name:"String",
		nl_description:"String",
		status:"String",
		todo:"todos",
		user:"users",
		user_id:"Int"
	},
	goals_aggregate:{
		aggregate:"goals_aggregate_fields",
		nodes:"goals"
	},
	goals_aggregate_fields:{
		avg:"goals_avg_fields",
		count:"Int",
		max:"goals_max_fields",
		min:"goals_min_fields",
		stddev:"goals_stddev_fields",
		stddev_pop:"goals_stddev_pop_fields",
		stddev_samp:"goals_stddev_samp_fields",
		sum:"goals_sum_fields",
		var_pop:"goals_var_pop_fields",
		var_samp:"goals_var_samp_fields",
		variance:"goals_variance_fields"
	},
	goals_avg_fields:{
		id:"Float",
		user_id:"Float"
	},
	goals_max_fields:{
		created:"timestamptz",
		id:"Int",
		name:"String",
		nl_description:"String",
		status:"String",
		user_id:"Int"
	},
	goals_min_fields:{
		created:"timestamptz",
		id:"Int",
		name:"String",
		nl_description:"String",
		status:"String",
		user_id:"Int"
	},
	goals_mutation_response:{
		affected_rows:"Int",
		returning:"goals"
	},
	goals_stddev_fields:{
		id:"Float",
		user_id:"Float"
	},
	goals_stddev_pop_fields:{
		id:"Float",
		user_id:"Float"
	},
	goals_stddev_samp_fields:{
		id:"Float",
		user_id:"Float"
	},
	goals_sum_fields:{
		id:"Int",
		user_id:"Int"
	},
	goals_var_pop_fields:{
		id:"Float",
		user_id:"Float"
	},
	goals_var_samp_fields:{
		id:"Float",
		user_id:"Float"
	},
	goals_variance_fields:{
		id:"Float",
		user_id:"Float"
	},
	interactions:{
		content:"String",
		content_type:"String",
		debug:"jsonb",
		embedding:"vector",
		events:"events",
		events_aggregate:"events_aggregate",
		id:"Int",
		match_score:"float8",
		timestamp:"timestamptz",
		user_id:"Int"
	},
	interactions_aggregate:{
		aggregate:"interactions_aggregate_fields",
		nodes:"interactions"
	},
	interactions_aggregate_fields:{
		avg:"interactions_avg_fields",
		count:"Int",
		max:"interactions_max_fields",
		min:"interactions_min_fields",
		stddev:"interactions_stddev_fields",
		stddev_pop:"interactions_stddev_pop_fields",
		stddev_samp:"interactions_stddev_samp_fields",
		sum:"interactions_sum_fields",
		var_pop:"interactions_var_pop_fields",
		var_samp:"interactions_var_samp_fields",
		variance:"interactions_variance_fields"
	},
	interactions_avg_fields:{
		id:"Float",
		match_score:"Float",
		user_id:"Float"
	},
	interactions_max_fields:{
		content:"String",
		content_type:"String",
		id:"Int",
		match_score:"float8",
		timestamp:"timestamptz",
		user_id:"Int"
	},
	interactions_min_fields:{
		content:"String",
		content_type:"String",
		id:"Int",
		match_score:"float8",
		timestamp:"timestamptz",
		user_id:"Int"
	},
	interactions_mutation_response:{
		affected_rows:"Int",
		returning:"interactions"
	},
	interactions_stddev_fields:{
		id:"Float",
		match_score:"Float",
		user_id:"Float"
	},
	interactions_stddev_pop_fields:{
		id:"Float",
		match_score:"Float",
		user_id:"Float"
	},
	interactions_stddev_samp_fields:{
		id:"Float",
		match_score:"Float",
		user_id:"Float"
	},
	interactions_sum_fields:{
		id:"Int",
		match_score:"float8",
		user_id:"Int"
	},
	interactions_var_pop_fields:{
		id:"Float",
		match_score:"Float",
		user_id:"Float"
	},
	interactions_var_samp_fields:{
		id:"Float",
		match_score:"Float",
		user_id:"Float"
	},
	interactions_variance_fields:{
		id:"Float",
		match_score:"Float",
		user_id:"Float"
	},
	locations:{
		id:"Int",
		location:"geography",
		name:"String",
		user_id:"Int"
	},
	locations_aggregate:{
		aggregate:"locations_aggregate_fields",
		nodes:"locations"
	},
	locations_aggregate_fields:{
		avg:"locations_avg_fields",
		count:"Int",
		max:"locations_max_fields",
		min:"locations_min_fields",
		stddev:"locations_stddev_fields",
		stddev_pop:"locations_stddev_pop_fields",
		stddev_samp:"locations_stddev_samp_fields",
		sum:"locations_sum_fields",
		var_pop:"locations_var_pop_fields",
		var_samp:"locations_var_samp_fields",
		variance:"locations_variance_fields"
	},
	locations_avg_fields:{
		id:"Float",
		user_id:"Float"
	},
	locations_max_fields:{
		id:"Int",
		name:"String",
		user_id:"Int"
	},
	locations_min_fields:{
		id:"Int",
		name:"String",
		user_id:"Int"
	},
	locations_mutation_response:{
		affected_rows:"Int",
		returning:"locations"
	},
	locations_stddev_fields:{
		id:"Float",
		user_id:"Float"
	},
	locations_stddev_pop_fields:{
		id:"Float",
		user_id:"Float"
	},
	locations_stddev_samp_fields:{
		id:"Float",
		user_id:"Float"
	},
	locations_sum_fields:{
		id:"Int",
		user_id:"Int"
	},
	locations_var_pop_fields:{
		id:"Float",
		user_id:"Float"
	},
	locations_var_samp_fields:{
		id:"Float",
		user_id:"Float"
	},
	locations_variance_fields:{
		id:"Float",
		user_id:"Float"
	},
	mutation_root:{
		delete_associations:"associations_mutation_response",
		delete_associations_by_pk:"associations",
		delete_event_tag:"event_tag_mutation_response",
		delete_event_tag_by_pk:"event_tag",
		delete_event_types:"event_types_mutation_response",
		delete_event_types_by_pk:"event_types",
		delete_events:"events_mutation_response",
		delete_events_by_pk:"events",
		delete_goals:"goals_mutation_response",
		delete_goals_by_pk:"goals",
		delete_interactions:"interactions_mutation_response",
		delete_interactions_by_pk:"interactions",
		delete_locations:"locations_mutation_response",
		delete_locations_by_pk:"locations",
		delete_object_types:"object_types_mutation_response",
		delete_object_types_by_pk:"object_types",
		delete_objects:"objects_mutation_response",
		delete_objects_by_pk:"objects",
		delete_todos:"todos_mutation_response",
		delete_todos_by_pk:"todos",
		delete_users:"users_mutation_response",
		delete_users_by_pk:"users",
		insert_associations:"associations_mutation_response",
		insert_associations_one:"associations",
		insert_event_tag:"event_tag_mutation_response",
		insert_event_tag_one:"event_tag",
		insert_event_types:"event_types_mutation_response",
		insert_event_types_one:"event_types",
		insert_events:"events_mutation_response",
		insert_events_one:"events",
		insert_goals:"goals_mutation_response",
		insert_goals_one:"goals",
		insert_interactions:"interactions_mutation_response",
		insert_interactions_one:"interactions",
		insert_locations:"locations_mutation_response",
		insert_locations_one:"locations",
		insert_object_types:"object_types_mutation_response",
		insert_object_types_one:"object_types",
		insert_objects:"objects_mutation_response",
		insert_objects_one:"objects",
		insert_todos:"todos_mutation_response",
		insert_todos_one:"todos",
		insert_users:"users_mutation_response",
		insert_users_one:"users",
		update_associations:"associations_mutation_response",
		update_associations_by_pk:"associations",
		update_associations_many:"associations_mutation_response",
		update_event_tag:"event_tag_mutation_response",
		update_event_tag_by_pk:"event_tag",
		update_event_tag_many:"event_tag_mutation_response",
		update_event_types:"event_types_mutation_response",
		update_event_types_by_pk:"event_types",
		update_event_types_many:"event_types_mutation_response",
		update_events:"events_mutation_response",
		update_events_by_pk:"events",
		update_events_many:"events_mutation_response",
		update_goals:"goals_mutation_response",
		update_goals_by_pk:"goals",
		update_goals_many:"goals_mutation_response",
		update_interactions:"interactions_mutation_response",
		update_interactions_by_pk:"interactions",
		update_interactions_many:"interactions_mutation_response",
		update_locations:"locations_mutation_response",
		update_locations_by_pk:"locations",
		update_locations_many:"locations_mutation_response",
		update_object_types:"object_types_mutation_response",
		update_object_types_by_pk:"object_types",
		update_object_types_many:"object_types_mutation_response",
		update_objects:"objects_mutation_response",
		update_objects_by_pk:"objects",
		update_objects_many:"objects_mutation_response",
		update_todos:"todos_mutation_response",
		update_todos_by_pk:"todos",
		update_todos_many:"todos_mutation_response",
		update_users:"users_mutation_response",
		update_users_by_pk:"users",
		update_users_many:"users_mutation_response"
	},
	object_types:{
		id:"String",
		metadata:"jsonb"
	},
	object_types_aggregate:{
		aggregate:"object_types_aggregate_fields",
		nodes:"object_types"
	},
	object_types_aggregate_fields:{
		count:"Int",
		max:"object_types_max_fields",
		min:"object_types_min_fields"
	},
	object_types_max_fields:{
		id:"String"
	},
	object_types_min_fields:{
		id:"String"
	},
	object_types_mutation_response:{
		affected_rows:"Int",
		returning:"object_types"
	},
	objects:{
		id:"Int",
		name:"String",
		object_type:"String"
	},
	objects_aggregate:{
		aggregate:"objects_aggregate_fields",
		nodes:"objects"
	},
	objects_aggregate_fields:{
		avg:"objects_avg_fields",
		count:"Int",
		max:"objects_max_fields",
		min:"objects_min_fields",
		stddev:"objects_stddev_fields",
		stddev_pop:"objects_stddev_pop_fields",
		stddev_samp:"objects_stddev_samp_fields",
		sum:"objects_sum_fields",
		var_pop:"objects_var_pop_fields",
		var_samp:"objects_var_samp_fields",
		variance:"objects_variance_fields"
	},
	objects_avg_fields:{
		id:"Float"
	},
	objects_max_fields:{
		id:"Int",
		name:"String",
		object_type:"String"
	},
	objects_min_fields:{
		id:"Int",
		name:"String",
		object_type:"String"
	},
	objects_mutation_response:{
		affected_rows:"Int",
		returning:"objects"
	},
	objects_stddev_fields:{
		id:"Float"
	},
	objects_stddev_pop_fields:{
		id:"Float"
	},
	objects_stddev_samp_fields:{
		id:"Float"
	},
	objects_sum_fields:{
		id:"Int"
	},
	objects_var_pop_fields:{
		id:"Float"
	},
	objects_var_samp_fields:{
		id:"Float"
	},
	objects_variance_fields:{
		id:"Float"
	},
	query_root:{
		associations:"associations",
		associations_aggregate:"associations_aggregate",
		associations_by_pk:"associations",
		closest_user_location:"locations",
		closest_user_location_aggregate:"locations_aggregate",
		event_tag:"event_tag",
		event_tag_aggregate:"event_tag_aggregate",
		event_tag_by_pk:"event_tag",
		event_types:"event_types",
		event_types_aggregate:"event_types_aggregate",
		event_types_by_pk:"event_types",
		events:"events",
		events_aggregate:"events_aggregate",
		events_by_pk:"events",
		fetch_associations:"associations",
		fetch_associations_aggregate:"associations_aggregate",
		goals:"goals",
		goals_aggregate:"goals_aggregate",
		goals_by_pk:"goals",
		interactions:"interactions",
		interactions_aggregate:"interactions_aggregate",
		interactions_by_pk:"interactions",
		locations:"locations",
		locations_aggregate:"locations_aggregate",
		locations_by_pk:"locations",
		match_interactions:"interactions",
		match_interactions_aggregate:"interactions_aggregate",
		object_types:"object_types",
		object_types_aggregate:"object_types_aggregate",
		object_types_by_pk:"object_types",
		objects:"objects",
		objects_aggregate:"objects_aggregate",
		objects_by_pk:"objects",
		todos:"todos",
		todos_aggregate:"todos_aggregate",
		todos_by_pk:"todos",
		users:"users",
		users_aggregate:"users_aggregate",
		users_by_pk:"users"
	},
	subscription_root:{
		associations:"associations",
		associations_aggregate:"associations_aggregate",
		associations_by_pk:"associations",
		associations_stream:"associations",
		closest_user_location:"locations",
		closest_user_location_aggregate:"locations_aggregate",
		event_tag:"event_tag",
		event_tag_aggregate:"event_tag_aggregate",
		event_tag_by_pk:"event_tag",
		event_tag_stream:"event_tag",
		event_types:"event_types",
		event_types_aggregate:"event_types_aggregate",
		event_types_by_pk:"event_types",
		event_types_stream:"event_types",
		events:"events",
		events_aggregate:"events_aggregate",
		events_by_pk:"events",
		events_stream:"events",
		fetch_associations:"associations",
		fetch_associations_aggregate:"associations_aggregate",
		goals:"goals",
		goals_aggregate:"goals_aggregate",
		goals_by_pk:"goals",
		goals_stream:"goals",
		interactions:"interactions",
		interactions_aggregate:"interactions_aggregate",
		interactions_by_pk:"interactions",
		interactions_stream:"interactions",
		locations:"locations",
		locations_aggregate:"locations_aggregate",
		locations_by_pk:"locations",
		locations_stream:"locations",
		match_interactions:"interactions",
		match_interactions_aggregate:"interactions_aggregate",
		object_types:"object_types",
		object_types_aggregate:"object_types_aggregate",
		object_types_by_pk:"object_types",
		object_types_stream:"object_types",
		objects:"objects",
		objects_aggregate:"objects_aggregate",
		objects_by_pk:"objects",
		objects_stream:"objects",
		todos:"todos",
		todos_aggregate:"todos_aggregate",
		todos_by_pk:"todos",
		todos_stream:"todos",
		users:"users",
		users_aggregate:"users_aggregate",
		users_by_pk:"users",
		users_stream:"users"
	},
	todos:{
		current_count:"Int",
		done_as_expected:"Boolean",
		due:"timestamptz",
		goal:"goals",
		goal_id:"Int",
		id:"Int",
		name:"String",
		status:"String",
		updated:"timestamptz",
		user:"users",
		user_id:"Int"
	},
	todos_aggregate:{
		aggregate:"todos_aggregate_fields",
		nodes:"todos"
	},
	todos_aggregate_fields:{
		avg:"todos_avg_fields",
		count:"Int",
		max:"todos_max_fields",
		min:"todos_min_fields",
		stddev:"todos_stddev_fields",
		stddev_pop:"todos_stddev_pop_fields",
		stddev_samp:"todos_stddev_samp_fields",
		sum:"todos_sum_fields",
		var_pop:"todos_var_pop_fields",
		var_samp:"todos_var_samp_fields",
		variance:"todos_variance_fields"
	},
	todos_avg_fields:{
		current_count:"Float",
		goal_id:"Float",
		id:"Float",
		user_id:"Float"
	},
	todos_max_fields:{
		current_count:"Int",
		due:"timestamptz",
		goal_id:"Int",
		id:"Int",
		name:"String",
		status:"String",
		updated:"timestamptz",
		user_id:"Int"
	},
	todos_min_fields:{
		current_count:"Int",
		due:"timestamptz",
		goal_id:"Int",
		id:"Int",
		name:"String",
		status:"String",
		updated:"timestamptz",
		user_id:"Int"
	},
	todos_mutation_response:{
		affected_rows:"Int",
		returning:"todos"
	},
	todos_stddev_fields:{
		current_count:"Float",
		goal_id:"Float",
		id:"Float",
		user_id:"Float"
	},
	todos_stddev_pop_fields:{
		current_count:"Float",
		goal_id:"Float",
		id:"Float",
		user_id:"Float"
	},
	todos_stddev_samp_fields:{
		current_count:"Float",
		goal_id:"Float",
		id:"Float",
		user_id:"Float"
	},
	todos_sum_fields:{
		current_count:"Int",
		goal_id:"Int",
		id:"Int",
		user_id:"Int"
	},
	todos_var_pop_fields:{
		current_count:"Float",
		goal_id:"Float",
		id:"Float",
		user_id:"Float"
	},
	todos_var_samp_fields:{
		current_count:"Float",
		goal_id:"Float",
		id:"Float",
		user_id:"Float"
	},
	todos_variance_fields:{
		current_count:"Float",
		goal_id:"Float",
		id:"Float",
		user_id:"Float"
	},
	users:{
		apple_id:"String",
		closest_user_location:"locations",
		config:"jsonb",
		events:"events",
		events_aggregate:"events_aggregate",
		id:"Int",
		language:"String",
		locations:"locations",
		locations_aggregate:"locations_aggregate",
		name:"String",
		timezone:"String"
	},
	users_aggregate:{
		aggregate:"users_aggregate_fields",
		nodes:"users"
	},
	users_aggregate_fields:{
		avg:"users_avg_fields",
		count:"Int",
		max:"users_max_fields",
		min:"users_min_fields",
		stddev:"users_stddev_fields",
		stddev_pop:"users_stddev_pop_fields",
		stddev_samp:"users_stddev_samp_fields",
		sum:"users_sum_fields",
		var_pop:"users_var_pop_fields",
		var_samp:"users_var_samp_fields",
		variance:"users_variance_fields"
	},
	users_avg_fields:{
		id:"Float"
	},
	users_max_fields:{
		apple_id:"String",
		id:"Int",
		language:"String",
		name:"String",
		timezone:"String"
	},
	users_min_fields:{
		apple_id:"String",
		id:"Int",
		language:"String",
		name:"String",
		timezone:"String"
	},
	users_mutation_response:{
		affected_rows:"Int",
		returning:"users"
	},
	users_stddev_fields:{
		id:"Float"
	},
	users_stddev_pop_fields:{
		id:"Float"
	},
	users_stddev_samp_fields:{
		id:"Float"
	},
	users_sum_fields:{
		id:"Int"
	},
	users_var_pop_fields:{
		id:"Float"
	},
	users_var_samp_fields:{
		id:"Float"
	},
	users_variance_fields:{
		id:"Float"
	}
}

export class GraphQLError extends Error {
    constructor(public response: GraphQLResponse) {
      super("");
      console.error(response);
    }
    toString() {
      return "GraphQL Response Error";
    }
  }



export type UnwrapPromise<T> = T extends Promise<infer R> ? R : T;
export type ZeusState<T extends (...args: any[]) => Promise<any>> = NonNullable<
  UnwrapPromise<ReturnType<T>>
>;
export type ZeusHook<
  T extends (
    ...args: any[]
  ) => Record<string, (...args: any[]) => Promise<any>>,
  N extends keyof ReturnType<T>
> = ZeusState<ReturnType<T>[N]>;

type Func<P extends any[], R> = (...args: P) => R;
type AnyFunc = Func<any, any>;

type WithTypeNameValue<T> = T & {
  __typename?: true;
};

type AliasType<T> = WithTypeNameValue<T> & {
  __alias?: Record<string, WithTypeNameValue<T>>;
};

type NotUndefined<T> = T extends undefined ? never : T;

export type ResolverType<F> = NotUndefined<F extends [infer ARGS, any] ? ARGS : undefined>;

export type ArgsType<F extends AnyFunc> = F extends Func<infer P, any> ? P : never;

interface GraphQLResponse {
  data?: Record<string, any>;
  errors?: Array<{
    message: string;
  }>;
}

export type ValuesOf<T> = T[keyof T];

export type MapResolve<SRC, DST> = SRC extends {
    __interface: infer INTERFACE;
    __resolve: Record<string, { __typename?: string }> & infer IMPLEMENTORS;
  }
  ?
  ValuesOf<{
    [k in (keyof SRC['__resolve'] & keyof DST)]: ({
      [rk in (keyof SRC['__resolve'][k] & keyof DST[k])]: LastMapTypeSRCResolver<SRC['__resolve'][k][rk], DST[k][rk]>
    } & {
      __typename: SRC['__resolve'][k]['__typename']
    })
  }>
  :
  never;

export type MapInterface<SRC, DST> = SRC extends {
    __interface: infer INTERFACE;
    __resolve: Record<string, { __typename?: string }> & infer IMPLEMENTORS;
  }
  ?
  (MapResolve<SRC, DST> extends never ? {} : MapResolve<SRC, DST>) & {
  [k in (keyof SRC['__interface'] & keyof DST)]: LastMapTypeSRCResolver<SRC['__interface'][k], DST[k]>
} : never;

export type ValueToUnion<T> = T extends {
  __typename: infer R;
}
  ? {
      [P in keyof Omit<T, '__typename'>]: T[P] & {
        __typename: R;
      };
    }
  : T;

export type ObjectToUnion<T> = {
  [P in keyof T]: T[P];
}[keyof T];

type Anify<T> = { [P in keyof T]?: any };


type LastMapTypeSRCResolver<SRC, DST> = SRC extends undefined
  ? undefined
  : SRC extends Array<infer AR>
  ? LastMapTypeSRCResolver<AR, DST>[]
  : SRC extends { __interface: any; __resolve: any }
  ? MapInterface<SRC, DST>
  : SRC extends { __union: any; __resolve: infer RESOLVE }
  ? ObjectToUnion<MapType<RESOLVE, ValueToUnion<DST>>>
  : DST extends boolean
  ? SRC
  : MapType<SRC, DST>;

export type MapType<SRC extends Anify<DST>, DST> = DST extends boolean
  ? SRC
  : DST extends {
      __alias: any;
    }
  ? {
      [A in keyof DST["__alias"]]: Required<SRC> extends Anify<
        DST["__alias"][A]
      >
        ? MapType<Required<SRC>, DST["__alias"][A]>
        : never;
    } &
      {
        [Key in keyof Omit<DST, "__alias">]: DST[Key] extends [
          any,
          infer PAYLOAD
        ]
          ? LastMapTypeSRCResolver<SRC[Key], PAYLOAD>
          : LastMapTypeSRCResolver<SRC[Key], DST[Key]>;
      }
  : {
      [Key in keyof DST]: DST[Key] extends [any, infer PAYLOAD]
        ? LastMapTypeSRCResolver<SRC[Key], PAYLOAD>
        : LastMapTypeSRCResolver<SRC[Key], DST[Key]>;
    };

type OperationToGraphQL<V, T> = <Z extends V>(o: Z | V, variables?: Record<string, any>) => Promise<MapType<T, Z>>;

type CastToGraphQL<V, T> = (
  resultOfYourQuery: any
) => <Z extends V>(o: Z | V) => MapType<T, Z>;

type fetchOptions = ArgsType<typeof fetch>;

export type SelectionFunction<V> = <T>(t: T | V) => T;
type FetchFunction = (query: string, variables?: Record<string, any>) => Promise<any>;



export const ZeusSelect = <T>() => ((t: any) => t) as SelectionFunction<T>;

export const ScalarResolver = (scalar: string, value: any) => {
  switch (scalar) {
    case 'String':
      return  `${JSON.stringify(value)}`;
    case 'Int':
      return `${value}`;
    case 'Float':
      return `${value}`;
    case 'Boolean':
      return `${value}`;
    case 'ID':
      return `"${value}"`;
    case 'enum':
      return `${value}`;
    case 'scalar':
      return `${value}`;
    default:
      return false;
  }
};


export const TypesPropsResolver = ({
    value,
    type,
    name,
    key,
    blockArrays
}: {
    value: any;
    type: string;
    name: string;
    key?: string;
    blockArrays?: boolean;
}): string => {
    if (value === null) {
        return `null`;
    }
    let resolvedValue = AllTypesProps[type][name];
    if (key) {
        resolvedValue = resolvedValue[key];
    }
    if (!resolvedValue) {
        throw new Error(`Cannot resolve ${type} ${name}${key ? ` ${key}` : ''}`)
    }
    const typeResolved = resolvedValue.type;
    const isArray = resolvedValue.array;
    const isArrayRequired = resolvedValue.arrayRequired;
    if (typeof value === 'string' && value.startsWith(`ZEUS_VAR$`)) {
        const isRequired = resolvedValue.required ? '!' : '';
        let t = `${typeResolved}`;
        if (isArray) {
          if (isRequired) {
              t = `${t}!`;
          }
          t = `[${t}]`;
          if(isArrayRequired){
            t = `${t}!`;
          }
        }else{
          if (isRequired) {
                t = `${t}!`;
          }
        }
        return `\$${value.split(`ZEUS_VAR$`)[1]}__ZEUS_VAR__${t}`;
    }
    if (isArray && !blockArrays) {
        return `[${value
        .map((v: any) => TypesPropsResolver({ value: v, type, name, key, blockArrays: true }))
        .join(',')}]`;
    }
    const reslovedScalar = ScalarResolver(typeResolved, value);
    if (!reslovedScalar) {
        const resolvedType = AllTypesProps[typeResolved];
        if (typeof resolvedType === 'object') {
        const argsKeys = Object.keys(resolvedType);
        return `{${argsKeys
            .filter((ak) => value[ak] !== undefined)
            .map(
            (ak) => `${ak}:${TypesPropsResolver({ value: value[ak], type: typeResolved, name: ak })}`
            )}}`;
        }
        return ScalarResolver(AllTypesProps[typeResolved], value) as string;
    }
    return reslovedScalar;
};


const isArrayFunction = (
  parent: string[],
  a: any[]
) => {
  const [values, r] = a;
  const [mainKey, key, ...keys] = parent;
  const keyValues = Object.keys(values).filter((k) => typeof values[k] !== 'undefined');

  if (!keys.length) {
      return keyValues.length > 0
        ? `(${keyValues
            .map(
              (v) =>
                `${v}:${TypesPropsResolver({
                  value: values[v],
                  type: mainKey,
                  name: key,
                  key: v
                })}`
            )
            .join(',')})${r ? traverseToSeekArrays(parent, r) : ''}`
        : traverseToSeekArrays(parent, r);
    }

  const [typeResolverKey] = keys.splice(keys.length - 1, 1);
  let valueToResolve = ReturnTypes[mainKey][key];
  for (const k of keys) {
    valueToResolve = ReturnTypes[valueToResolve][k];
  }

  const argumentString =
    keyValues.length > 0
      ? `(${keyValues
          .map(
            (v) =>
              `${v}:${TypesPropsResolver({
                value: values[v],
                type: valueToResolve,
                name: typeResolverKey,
                key: v
              })}`
          )
          .join(',')})${r ? traverseToSeekArrays(parent, r) : ''}`
      : traverseToSeekArrays(parent, r);
  return argumentString;
};


const resolveKV = (k: string, v: boolean | string | { [x: string]: boolean | string }) =>
  typeof v === 'boolean' ? k : typeof v === 'object' ? `${k}{${objectToTree(v)}}` : `${k}${v}`;


const objectToTree = (o: { [x: string]: boolean | string }): string =>
  `{${Object.keys(o).map((k) => `${resolveKV(k, o[k])}`).join(' ')}}`;


const traverseToSeekArrays = (parent: string[], a?: any): string => {
  if (!a) return '';
  if (Object.keys(a).length === 0) {
    return '';
  }
  let b: Record<string, any> = {};
  if (Array.isArray(a)) {
    return isArrayFunction([...parent], a);
  } else {
    if (typeof a === 'object') {
      Object.keys(a)
        .filter((k) => typeof a[k] !== 'undefined')
        .map((k) => {
        if (k === '__alias') {
          Object.keys(a[k]).map((aliasKey) => {
            const aliasOperations = a[k][aliasKey];
            const aliasOperationName = Object.keys(aliasOperations)[0];
            const aliasOperation = aliasOperations[aliasOperationName];
            b[
              `${aliasOperationName}__alias__${aliasKey}: ${aliasOperationName}`
            ] = traverseToSeekArrays([...parent, aliasOperationName], aliasOperation);
          });
        } else {
          b[k] = traverseToSeekArrays([...parent, k], a[k]);
        }
      });
    } else {
      return '';
    }
  }
  return objectToTree(b);
};  


const buildQuery = (type: string, a?: Record<any, any>) => 
  traverseToSeekArrays([type], a);


const inspectVariables = (query: string) => {
  const regex = /\$\b\w*__ZEUS_VAR__\[?[^!^\]^\s^,^\)^\}]*[!]?[\]]?[!]?/g;
  let result;
  const AllVariables: string[] = [];
  while ((result = regex.exec(query))) {
    if (AllVariables.includes(result[0])) {
      continue;
    }
    AllVariables.push(result[0]);
  }
  if (!AllVariables.length) {
    return query;
  }
  let filteredQuery = query;
  AllVariables.forEach((variable) => {
    while (filteredQuery.includes(variable)) {
      filteredQuery = filteredQuery.replace(variable, variable.split('__ZEUS_VAR__')[0]);
    }
  });
  return `(${AllVariables.map((a) => a.split('__ZEUS_VAR__'))
    .map(([variableName, variableType]) => `${variableName}:${variableType}`)
    .join(', ')})${filteredQuery}`;
};


const queryConstruct = (t: 'query' | 'mutation' | 'subscription', tName: string) => (o: Record<any, any>) =>
  `${t.toLowerCase()}${inspectVariables(buildQuery(tName, o))}`;
  

const fullChainConstruct = (fn: FetchFunction) => (t: 'query' | 'mutation' | 'subscription', tName: string) => (
  o: Record<any, any>,
  variables?: Record<string, any>,
) => fn(queryConstruct(t, tName)(o), variables).then((r:any) => { 
  seekForAliases(r)
  return r
});


const seekForAliases = (response: any) => {
  const traverseAlias = (value: any) => {
    if (Array.isArray(value)) {
      value.forEach(seekForAliases);
    } else {
      if (typeof value === 'object') {
        seekForAliases(value);
      }
    }
  };
  if (typeof response === 'object' && response) {
    const keys = Object.keys(response);
    if (keys.length < 1) {
      return;
    }
    keys.forEach((k) => {
      const value = response[k];
      if (k.indexOf('__alias__') !== -1) {
        const [operation, alias] = k.split('__alias__');
        response[alias] = {
          [operation]: value,
        };
        delete response[k];
      }
      traverseAlias(value);
    });
  }
};


export const $ = (t: TemplateStringsArray): any => `ZEUS_VAR$${t.join('')}`;


const handleFetchResponse = (
  response: Parameters<Extract<Parameters<ReturnType<typeof fetch>['then']>[0], Function>>[0]
): Promise<GraphQLResponse> => {
  if (!response.ok) {
    return new Promise((_, reject) => {
      response.text().then(text => {
        try { reject(JSON.parse(text)); }
        catch (err) { reject(text); }
      }).catch(reject);
    });
  }
  return response.json();
};

const apiFetch = (options: fetchOptions) => (query: string, variables: Record<string, any> = {}) => {
    let fetchFunction;
    let queryString = query;
    let fetchOptions = options[1] || {};
    try {
        fetchFunction = require('node-fetch');
    } catch (error) {
        throw new Error("Please install 'node-fetch' to use zeus in nodejs environment");
    }
    if (fetchOptions.method && fetchOptions.method === 'GET') {
      try {
          queryString = require('querystring').stringify(query);
      } catch (error) {
          throw new Error("Something gone wrong 'querystring' is a part of nodejs environment");
      }
      return fetchFunction(`${options[0]}?query=${queryString}`, fetchOptions)
        .then(handleFetchResponse)
        .then((response: GraphQLResponse) => {
          if (response.errors) {
            throw new GraphQLError(response);
          }
          return response.data;
        });
    }
    return fetchFunction(`${options[0]}`, {
      body: JSON.stringify({ query: queryString, variables }),
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      ...fetchOptions
    })
      .then(handleFetchResponse)
      .then((response: GraphQLResponse) => {
        if (response.errors) {
          throw new GraphQLError(response);
        }
        return response.data;
      });
  };
  


export const Thunder = (fn: FetchFunction) => ({
  query: ((o: any, variables) =>
    fullChainConstruct(fn)('query', 'query_root')(o, variables).then(
      (response: any) => response
    )) as OperationToGraphQL<ValueTypes["query_root"],query_root>,
mutation: ((o: any, variables) =>
    fullChainConstruct(fn)('mutation', 'mutation_root')(o, variables).then(
      (response: any) => response
    )) as OperationToGraphQL<ValueTypes["mutation_root"],mutation_root>,
subscription: ((o: any, variables) =>
    fullChainConstruct(fn)('subscription', 'subscription_root')(o, variables).then(
      (response: any) => response
    )) as OperationToGraphQL<ValueTypes["subscription_root"],subscription_root>
});

export const Chain = (...options: fetchOptions) => ({
  query: ((o: any, variables) =>
    fullChainConstruct(apiFetch(options))('query', 'query_root')(o, variables).then(
      (response: any) => response
    )) as OperationToGraphQL<ValueTypes["query_root"],query_root>,
mutation: ((o: any, variables) =>
    fullChainConstruct(apiFetch(options))('mutation', 'mutation_root')(o, variables).then(
      (response: any) => response
    )) as OperationToGraphQL<ValueTypes["mutation_root"],mutation_root>,
subscription: ((o: any, variables) =>
    fullChainConstruct(apiFetch(options))('subscription', 'subscription_root')(o, variables).then(
      (response: any) => response
    )) as OperationToGraphQL<ValueTypes["subscription_root"],subscription_root>
});
export const Zeus = {
  query: (o:ValueTypes["query_root"]) => queryConstruct('query', 'query_root')(o),
mutation: (o:ValueTypes["mutation_root"]) => queryConstruct('mutation', 'mutation_root')(o),
subscription: (o:ValueTypes["subscription_root"]) => queryConstruct('subscription', 'subscription_root')(o)
};
export const Cast = {
  query: ((o: any) => (_: any) => o) as CastToGraphQL<
  ValueTypes["query_root"],
  query_root
>,
mutation: ((o: any) => (_: any) => o) as CastToGraphQL<
  ValueTypes["mutation_root"],
  mutation_root
>,
subscription: ((o: any) => (_: any) => o) as CastToGraphQL<
  ValueTypes["subscription_root"],
  subscription_root
>
};
export const Selectors = {
  query: ZeusSelect<ValueTypes["query_root"]>(),
mutation: ZeusSelect<ValueTypes["mutation_root"]>(),
subscription: ZeusSelect<ValueTypes["subscription_root"]>()
};
  

export const Gql = Chain('https://ai-tracker-hasura-a1071aad7764.herokuapp.com/v1/graphql')