# fmir 0.1.1

# fmir 0.1.0.9000

* HTTP errors now include the description provided by the API.

* `fmi_split_long_query()` is no longer exported, as with current design,
  there isn't any scenario in which a user should have to call it directly.

# fmir 0.1.0

* New `fmi_split_long_query()` can be used to split queries that are too long
  for their type into multiple shorter queries that fit (cf. #2).
  
* `fmi_query()` is now vectorised with respect to the query parameters. This
  means you can now (for example) simultaneously create queries for multiple
  places like `fmi_query(place = c("Oulu", "Espoo"))` (#1).

* `fmi_data()` now:
    1. Takes vectorized queries and returns the result in a single `tbl_df`. It
       is not advisable to mix query types (e.g. `"daily"` and `"monthly"`) in
       a single query vector as that will result in malformed data.
    2. Recognizes when queries span a time interval too long for the type and
       automatically splits them with `fmi_split_long_query()` (#2).
    3. Adds a column to its output data specifying the `place` in the query.

* You can now use the environment variable `FMIR_API_KEY` to remember your API
  key across sessions.

# fmir 0.0.0.9000

* Added a `NEWS.md` file to track changes to the package.
