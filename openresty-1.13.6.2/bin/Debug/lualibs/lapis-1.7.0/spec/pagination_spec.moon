config = require "lapis.config"
config.default_config.postgres = {backend: "pgmoon"}
config.reset true

db = require "lapis.db.postgres"
import Model from require "lapis.db.postgres.model"
import stub_queries, assert_queries from require "spec.helpers"

import escape_pattern from require "lapis.util"

describe "lapis.db.pagination", ->
  get_queries, mock_query = stub_queries!

  with old = assert_queries
    assert_queries = (expected) ->
      old expected, get_queries!

  describe "offset paginator", ->
    local Things, OffsetPaginator

    before_each ->
      class Things extends Model
      import OffsetPaginator from require "lapis.db.pagination"

    it "gets pages", ->
      pager = OffsetPaginator(Things)
      assert.same {}, pager\get_page 1
      assert.same {}, pager\get_page 2
      assert.same {}, pager\get_page 3

      assert_queries {
        [[SELECT * from "things" LIMIT 10 OFFSET 0]]
        [[SELECT * from "things" LIMIT 10 OFFSET 10]]
        [[SELECT * from "things" LIMIT 10 OFFSET 20]]
      }

    it "gets pages with per_page", ->
      pager = OffsetPaginator Things, {
        per_page: 25
      }

      assert.same {}, pager\get_page 1
      assert.same {}, pager\get_page 2
      assert.same {}, pager\get_page 3

      assert_queries {
        [[SELECT * from "things" LIMIT 25 OFFSET 0]]
        [[SELECT * from "things" LIMIT 25 OFFSET 25]]
        [[SELECT * from "things" LIMIT 25 OFFSET 50]]
      }

    it "paginates with clause", ->
      mock_query "COUNT%(%*%)", {{ c: 127 }}

      p = OffsetPaginator Things, [[where group_id = ? order by name asc]], 123

      p\get_all!
      assert.same 127, p\total_items!
      assert.same 13, p\num_pages!
      assert.falsy p\has_items!

      p\get_page 1
      p\get_page 4

      assert_queries {
        'SELECT * from "things" where group_id = 123 order by name asc'
        'SELECT COUNT(*) AS c FROM "things" where group_id = 123 '
        'SELECT 1 FROM "things" where group_id = 123 limit 1'
        'SELECT * from "things" where group_id = 123 order by name asc LIMIT 10 OFFSET 0'
        'SELECT * from "things" where group_id = 123 order by name asc LIMIT 10 OFFSET 30'
      }

    it "ignores excess parameter", ->
      pager = OffsetPaginator Things, [[order by name asc]], 123, per_page: 25
      pager\get_page 3

      assert_queries {
        'SELECT * from "things" order by name asc LIMIT 25 OFFSET 50'
      }

    it "supports empty clause", ->
      p3 = OffsetPaginator Things, "", fields: "hello, world", per_page: 12
      p3\get_page 2

      assert_queries {
        'SELECT hello, world from "things" LIMIT 12 OFFSET 12'
      }

    it "supports options only", ->
      pager = OffsetPaginator Things, fields: "hello, world", per_page: 12
      pager\get_page 2

      assert_queries {
        'SELECT hello, world from "things" LIMIT 12 OFFSET 12'
      }

    it "supports ordered clause", ->
      mock_query "COUNT%(%*%)", {{ c: 127 }}
      pager = OffsetPaginator Things, [[order by BLAH]]
      pager\get_page 3
      pager\get_page 4
      pager\total_items!
      pager\has_items!

      assert_queries {
        'SELECT * from "things" order by BLAH LIMIT 10 OFFSET 20'
        'SELECT * from "things" order by BLAH LIMIT 10 OFFSET 30'
        'SELECT COUNT(*) AS c FROM "things" '
        'SELECT 1 FROM "things" limit 1'
      }

    it "supports join clause", ->
      mock_query "COUNT%(%*%)", {{ c: 127 }}

      pager = OffsetPaginator Things, [[join whales on color = blue order by BLAH]]
      pager\get_page 2
      pager\total_items!
      pager\has_items!

      assert_queries {
        'SELECT * from "things" join whales on color = blue order by BLAH LIMIT 10 OFFSET 10'
        'SELECT COUNT(*) AS c FROM "things" join whales on color = blue '
        'SELECT 1 FROM "things" join whales on color = blue limit 1'
      }

    it "builds clause with ? when no parameter is provided", ->
      mock_query "COUNT%(%*%)", {{ c: 127 }}

      pager = OffsetPaginator Things, "where color = '?'"
      pager\get_page 3
      pager\total_items!

      assert_queries {
        [[SELECT * from "things" where color = '?' LIMIT 10 OFFSET 20]]
        [[SELECT COUNT(*) AS c FROM "things" where color = '?']]
      }

    it "iterates through pages", ->
      mock_query "OFFSET 0", { { id: 101 }, { id: 202 } }
      mock_query "OFFSET 10", { { id: 102 } }
      mock_query "OFFSET 20", { }

      pager = OffsetPaginator Things

      assert.same {
        { { id: 101 }, { id: 202 } }
        { { id: 102 } }
      }, [page for page in pager\each_page!]

      assert.same {
        { id: 101 }
        { id: 202 }
        { id: 102 }
      }, [item for item in pager\each_item!]

      assert_queries {
        [[SELECT * from "things" LIMIT 10 OFFSET 0]]
        [[SELECT * from "things" LIMIT 10 OFFSET 10]]
        [[SELECT * from "things" LIMIT 10 OFFSET 20]]

        [[SELECT * from "things" LIMIT 10 OFFSET 0]]
        [[SELECT * from "things" LIMIT 10 OFFSET 10]]
        [[SELECT * from "things" LIMIT 10 OFFSET 20]]
      }


  describe "ordered paginator", ->
    local OrderedPaginator, Things

    before_each ->
      import OrderedPaginator from require "lapis.db.pagination"
      class Things extends Model

    it "gets page with single key", ->
      pager = OrderedPaginator Things, "id", "where color = blue"
      res, np = pager\get_page!

      res, np = pager\get_page 123

      assert_queries {
        'SELECT * from "things" where color = blue order by "things"."id" ASC limit 10'
        'SELECT * from "things" where "things"."id" > 123 and (color = blue) order by "things"."id" ASC limit 10'
      }

    it "gets pages for multiple keys", ->
      mock_query "SELECT", { { id: 101, updated_at: 300 }, { id: 102, updated_at: 301 } }

      pager = OrderedPaginator Things, {"id", "updated_at"}, "where color = blue"

      res, next_id, next_updated_at = pager\get_page!

      assert.same 102, next_id
      assert.same 301, next_updated_at

      pager\after!
      pager\before!

      pager\after 100
      pager\before 32

      pager\after 100, 200
      pager\before 32, 42

      assert_queries {
        'SELECT * from "things" where color = blue order by "things"."id" ASC, "things"."updated_at" ASC limit 10'

        'SELECT * from "things" where color = blue order by "things"."id" ASC, "things"."updated_at" ASC limit 10'
        'SELECT * from "things" where color = blue order by "things"."id" DESC, "things"."updated_at" DESC limit 10'

        'SELECT * from "things" where "things"."id" > 100 and (color = blue) order by "things"."id" ASC, "things"."updated_at" ASC limit 10'
        'SELECT * from "things" where "things"."id" < 32 and (color = blue) order by "things"."id" DESC, "things"."updated_at" DESC limit 10'

        'SELECT * from "things" where ("things"."id", "things"."updated_at") > (100, 200) and (color = blue) order by "things"."id" ASC, "things"."updated_at" ASC limit 10'
        'SELECT * from "things" where ("things"."id", "things"."updated_at") < (32, 42) and (color = blue) order by "things"."id" DESC, "things"."updated_at" DESC limit 10'
      }

    it "iterates through pages", ->
      -- base query
      mock_query 'from "things" order by', { { id: 101 }, { id: 202 } }
      mock_query '"things"."id" > 202', { { id: 302 } }
      mock_query '"things"."id" > 302', { }

      pager = OrderedPaginator Things, "id"

      assert.same {
        { { id: 101 }, { id: 202 } }
        { { id: 302 } }
      }, [page for page in pager\each_page!]


      pager = OrderedPaginator Things, "id"
      assert.same {
        { id: 101 }
        { id: 202 }
        { id: 302 }
      }, [item for item in pager\each_item!]

      assert_queries {
        [[SELECT * from "things" order by "things"."id" ASC limit 10]]
        [[SELECT * from "things" where "things"."id" > 202 order by "things"."id" ASC limit 10]]
        [[SELECT * from "things" where "things"."id" > 302 order by "things"."id" ASC limit 10]]

        [[SELECT * from "things" order by "things"."id" ASC limit 10]]
        [[SELECT * from "things" where "things"."id" > 202 order by "things"."id" ASC limit 10]]
        [[SELECT * from "things" where "things"."id" > 302 order by "things"."id" ASC limit 10]]
      }

    it "iterates through pages with multiple keys", ->
      mock_query 'where color = blue order by', {
        { id: 101, updated_at: 'a' }
        { id: 101, updated_at: 'b' }
        { id: 102, updated_at: 'a' }
      }

      mock_query escape_pattern([[> (102, 'a')]]), {
        { id: 301, updated_at: 'd' }
        { id: 301, updated_at: 'e' }
      }

      mock_query escape_pattern([[> (301, 'e')]]), { }

      pager = OrderedPaginator Things, {"id", "updated_at"}, "where color = blue"

      assert.same {
        {
          { id: 101, updated_at: 'a' }
          { id: 101, updated_at: 'b' }
          { id: 102, updated_at: 'a' }
        }
        {
          { id: 301, updated_at: 'd' }
          { id: 301, updated_at: 'e' }
        }
      }, [page for page in pager\each_page!]

      assert_queries {
        [[SELECT * from "things" where color = blue order by "things"."id" ASC, "things"."updated_at" ASC limit 10]]
        [[SELECT * from "things" where ("things"."id", "things"."updated_at") > (102, 'a') and (color = blue) order by "things"."id" ASC, "things"."updated_at" ASC limit 10]]
        [[SELECT * from "things" where ("things"."id", "things"."updated_at") > (301, 'e') and (color = blue) order by "things"."id" ASC, "things"."updated_at" ASC limit 10]]
      }
