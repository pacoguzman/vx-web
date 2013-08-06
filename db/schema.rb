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

ActiveRecord::Schema.define(version: 20130806224726) do

  create_table "github_organization_members", force: true do |t|
    t.integer  "organization_id", null: false
    t.integer  "user_id",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "github_organization_members", ["organization_id", "user_id"], name: "index_github_organization_members_on_org_and_user", unique: true

  create_table "github_organizations", force: true do |t|
    t.string   "login",      null: false
    t.string   "url",        null: false
    t.string   "avatar_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "github_organizations", ["login"], name: "index_github_organizations_on_login", unique: true

  create_table "github_team_members", force: true do |t|
    t.integer  "user_id",    null: false
    t.integer  "team_id",    null: false
    t.string   "permission", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "github_team_members", ["user_id", "team_id"], name: "index_github_team_members_on_user_id_and_team_id", unique: true

  create_table "github_teams", force: true do |t|
    t.string   "name",            null: false
    t.integer  "organization_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", force: true do |t|
    t.string   "name",        null: false
    t.string   "url",         null: false
    t.text     "provider",    null: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_identities", force: true do |t|
    t.integer  "user_id",    null: false
    t.string   "provider",   null: false
    t.string   "token",      null: false
    t.string   "uid",        null: false
    t.string   "login",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_identities", ["user_id", "provider"], name: "index_user_identities_on_user_id_and_provider", unique: true

  create_table "users", force: true do |t|
    t.string   "email",      null: false
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true

end
