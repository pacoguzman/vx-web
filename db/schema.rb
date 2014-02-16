# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140214185954) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "artifacts", force: true do |t|
    t.integer  "build_id",     null: false
    t.string   "file",         null: false
    t.string   "content_type", null: false
    t.string   "file_size",    null: false
    t.string   "file_name",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "artifacts", ["build_id"], name: "index_artifacts_on_build_id", using: :btree

  create_table "builds", force: true do |t|
    t.integer  "number",                      null: false
    t.integer  "project_id",                  null: false
    t.string   "sha",                         null: false
    t.string   "branch",                      null: false
    t.integer  "pull_request_id"
    t.string   "author"
    t.text     "message"
    t.integer  "status",          default: 0, null: false
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "author_email"
    t.string   "http_url"
    t.string   "branch_label"
    t.text     "source",                      null: false
    t.string   "token",                       null: false
  end

  add_index "builds", ["project_id", "number"], name: "index_builds_on_project_id_and_number", unique: true, using: :btree

  create_table "cached_files", force: true do |t|
    t.integer  "project_id",   null: false
    t.string   "file",         null: false
    t.string   "content_type", null: false
    t.integer  "file_size",    null: false
    t.string   "file_name",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cached_files", ["project_id", "file_name"], name: "index_cached_files_on_project_id_and_file_name", unique: true, using: :btree

  create_table "job_logs", force: true do |t|
    t.integer "job_id"
    t.integer "tm"
    t.text    "data"
  end

  add_index "job_logs", ["job_id"], name: "index_job_logs_on_job_id", using: :btree

  create_table "jobs", force: true do |t|
    t.integer  "build_id",    null: false
    t.integer  "number",      null: false
    t.integer  "status",      null: false
    t.hstore   "matrix"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "source",      null: false
    t.string   "kind"
  end

  add_index "jobs", ["build_id", "number"], name: "index_jobs_on_build_id_and_number", unique: true, using: :btree

  create_table "project_subscriptions", force: true do |t|
    t.integer  "project_id",                null: false
    t.integer  "user_id",                   null: false
    t.boolean  "subscribe",  default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_subscriptions", ["project_id", "user_id"], name: "index_project_subscriptions_on_project_id_and_user_id", unique: true, using: :btree
  add_index "project_subscriptions", ["project_id"], name: "index_project_subscriptions_on_project_id", using: :btree

  create_table "projects", force: true do |t|
    t.string   "name",                   null: false
    t.string   "http_url",               null: false
    t.string   "clone_url",              null: false
    t.text     "description"
    t.text     "deploy_key",             null: false
    t.string   "token",                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_repo_id"
    t.integer  "last_build_id"
    t.string   "last_build_status_name"
    t.datetime "last_build_at"
  end

  add_index "projects", ["name"], name: "index_projects_on_name", unique: true, using: :btree
  add_index "projects", ["token"], name: "index_projects_on_token", unique: true, using: :btree

  create_table "user_identities", force: true do |t|
    t.integer  "user_id",    null: false
    t.string   "provider",   null: false
    t.string   "token",      null: false
    t.string   "uid",        null: false
    t.string   "login",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url",        null: false
    t.string   "version"
  end

  add_index "user_identities", ["user_id", "provider", "url"], name: "index_user_identities_on_user_id_and_provider_and_url", unique: true, using: :btree

  create_table "user_repos", force: true do |t|
    t.string   "organization_login"
    t.string   "full_name",                          null: false
    t.boolean  "is_private",                         null: false
    t.string   "ssh_url",                            null: false
    t.string   "html_url",                           null: false
    t.boolean  "subscribed",         default: false, null: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "identity_id",                        null: false
    t.integer  "external_id",                        null: false
  end

  add_index "user_repos", ["full_name", "identity_id"], name: "index_user_repos_on_full_name_and_identity_id", unique: true, using: :btree
  add_index "user_repos", ["identity_id", "external_id"], name: "index_user_repos_on_identity_id_and_external_id", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "email",      null: false
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
