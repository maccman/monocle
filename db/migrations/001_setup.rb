Sequel.migration do
  change do
    run %{
      CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;
    }

    create_table(:users) do
      column :id, "uuid", :default=>Sequel::LiteralString.new("uuid_generate_v4()"), :null=>false
      column :iid, :serial, :null=>false
      column :uid, "text"
      column :provider, "text"
      column :handle, "text"
      column :about, "text"
      column :email, "text"
      column :url, "text"
      column :twitter, "text"
      column :karma, "integer", :default=>0
      column :name, "text"
      column :auth, "json"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
      column :active, "boolean", :default=>false
      column :admin, "boolean", :default=>false
      column :registered, "boolean"
      foreign_key :parent_id, :users, :type=>"uuid", :key=>[:id]
      column :invites_count, "integer", :default=>0
      column :github, "text"
      column :activated_at, "timestamp without time zone"
      column :secret, "text"
      column :manifesto, "boolean", :default=>false

      primary_key [:id]

      index [:handle]
      index [:iid], :unique=>true
      index [:uid], :unique=>true
    end

    create_table(:posts) do
      column :id, "uuid", :default=>Sequel::LiteralString.new("uuid_generate_v4()"), :null=>false
      column :iid, "serial", :null=>false
      column :visits, "integer", :default=>0
      column :title, "text"
      column :url, "text"
      column :slug, "text"
      column :oembed, "json"
      column :html_title, "text"
      column :link_icons, "json"
      column :domain, "text"
      column :votes, "integer", :default=>0
      column :score, "double precision", :default=>0.0
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
      foreign_key :user_id, :users, :type=>"uuid", :key=>[:id]
      column :open_graph, "json"
      column :body, "text"
      column :summary, "text"
      column :tweet_id, "text"
      column :published_at, "timestamp without time zone"
      column :comment_count, "integer", :default=>0, :null=>false
      column :comments_count, "integer", :default=>0, :null=>false
      column :user_handle, "text"
      column :voted_user_ids, "uuid[]", :default=>Sequel::LiteralString.new("'{}'::uuid[]")
      column :preview_url, "text"

      primary_key [:id]

      index [:iid], :unique=>true
      index [:published_at]
      index [:slug], :unique=>true
      index [:user_id]
    end

    create_table(:user_invites) do
      column :id, "uuid", :default=>Sequel::LiteralString.new("uuid_generate_v4()"), :null=>false
      column :iid, "serial", :null=>false
      column :email, "text"
      column :code, "text"
      foreign_key :user_id, :users, :type=>"uuid", :key=>[:id]
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
      column :twitter, "character varying(255)"
      column :github, "text"
      foreign_key :invited_user_id, :users, :type=>"uuid", :key=>[:id]

      primary_key [:id]

      index [:code], :name=>:user_invites_code_key, :unique=>true
      index [:user_id]
    end

    create_table(:comments) do
      column :id, "uuid", :default=>Sequel::LiteralString.new("uuid_generate_v4()"), :null=>false
      column :iid, "serial", :null=>false
      foreign_key :user_id, :users, :type=>"uuid", :key=>[:id]
      foreign_key :post_id, :posts, :type=>"uuid", :key=>[:id]
      column :body, "text"
      column :votes, "integer", :default=>0
      column :score, "double precision", :default=>0.0
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
      foreign_key :parent_id, :comments, :type=>"uuid", :key=>[:id]

      primary_key [:id]

      index [:iid], :unique=>true
    end

    create_table(:post_visits) do
      column :id, "uuid", :default=>Sequel::LiteralString.new("uuid_generate_v4()"), :null=>false
      column :iid, "serial", :null=>false
      foreign_key :user_id, :users, :type=>"uuid", :key=>[:id]
      foreign_key :post_id, :posts, :type=>"uuid", :key=>[:id]
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"

      primary_key [:id]

      index [:post_id]
      index [:user_id]
    end

    create_table(:post_votes) do
      column :id, "uuid", :default=>Sequel::LiteralString.new("uuid_generate_v4()"), :null=>false
      column :iid, "serial", :null=>false
      foreign_key :user_id, :users, :type=>"uuid", :key=>[:id]
      foreign_key :post_id, :posts, :type=>"uuid", :key=>[:id]
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"

      primary_key [:id]

      index [:post_id]
      index [:user_id]
    end

    create_table(:comment_votes) do
      column :id, "uuid", :default=>Sequel::LiteralString.new("uuid_generate_v4()"), :null=>false
      column :iid, "serial", :null=>false
      foreign_key :user_id, :users, :type=>"uuid", :key=>[:id]
      foreign_key :comment_id, :comments, :type=>"uuid", :key=>[:id]
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"

      primary_key [:id]

      index [:comment_id]
      index [:user_id]
    end
  end
end