Sequel.migration do
  change do
    create_table(:schema_info) do
      Integer :version, :default=>0, :null=>false
    end

    create_table(:users, :ignore_index_errors=>true) do
      String :id, :null=>false
      Integer :iid, :null=>false
      String :uid, :text=>true
      String :provider, :text=>true
      String :handle, :text=>true
      String :about, :text=>true
      String :email, :text=>true
      String :url, :text=>true
      String :twitter, :text=>true
      Integer :karma, :default=>0
      String :name, :text=>true
      String :auth
      DateTime :created_at
      DateTime :updated_at
      TrueClass :admin, :default=>false
      TrueClass :registered
      foreign_key :parent_id, :users, :type=>String, :key=>[:id]
      Integer :invites_count, :default=>0
      String :github, :text=>true
      String :secret, :text=>true
      TrueClass :manifesto, :default=>false

      primary_key [:id]

      index [:handle]
      index [:iid], :unique=>true
      index [:uid], :unique=>true
    end

    create_table(:posts, :ignore_index_errors=>true) do
      String :id, :null=>false
      Integer :iid, :null=>false
      Integer :visits, :default=>0
      String :title, :text=>true
      String :url, :text=>true
      String :slug, :text=>true
      String :oembed
      String :html_title, :text=>true
      String :link_icons
      String :domain, :text=>true
      Integer :votes, :default=>0
      Float :score, :default=>0.0
      DateTime :created_at
      DateTime :updated_at
      foreign_key :user_id, :users, :type=>String, :key=>[:id]
      String :open_graph
      String :body, :text=>true
      String :summary, :text=>true
      String :tweet_id, :text=>true
      DateTime :scheduled_at
      DateTime :published_at
      Integer :comment_count, :default=>0, :null=>false
      Integer :comments_count, :default=>0, :null=>false
      String :user_handle, :text=>true
      String :voted_user_ids
      String :preview_url, :text=>true

      primary_key [:id]

      index [:iid], :unique=>true
      index [:published_at]
      index [:slug], :unique=>true
      index [:user_id]
    end

    create_table(:user_invites, :ignore_index_errors=>true) do
      String :id, :null=>false
      Integer :iid, :null=>false
      String :email, :text=>true
      String :code, :text=>true
      foreign_key :user_id, :users, :type=>String, :key=>[:id]
      DateTime :created_at
      DateTime :updated_at
      String :twitter, :size=>255
      String :github, :text=>true
      foreign_key :invited_user_id, :users, :type=>String, :key=>[:id]

      primary_key [:id]

      index [:code], :name=>:user_invites_code_key, :unique=>true
      index [:user_id]
    end

    create_table(:comments, :ignore_index_errors=>true) do
      String :id, :null=>false
      Integer :iid, :null=>false
      foreign_key :user_id, :users, :type=>String, :key=>[:id]
      foreign_key :post_id, :posts, :type=>String, :key=>[:id]
      String :body, :text=>true
      Integer :votes, :default=>0
      Float :score, :default=>0.0
      DateTime :created_at
      DateTime :updated_at
      foreign_key :parent_id, :comments, :type=>String, :key=>[:id]

      primary_key [:id]

      index [:iid], :unique=>true
    end

    create_table(:post_visits, :ignore_index_errors=>true) do
      String :id, :null=>false
      Integer :iid, :null=>false
      foreign_key :user_id, :users, :type=>String, :key=>[:id]
      foreign_key :post_id, :posts, :type=>String, :key=>[:id]
      DateTime :created_at
      DateTime :updated_at

      primary_key [:id]

      index [:post_id]
      index [:user_id]
    end

    create_table(:post_votes, :ignore_index_errors=>true) do
      String :id, :null=>false
      Integer :iid, :null=>false
      foreign_key :user_id, :users, :type=>String, :key=>[:id]
      foreign_key :post_id, :posts, :type=>String, :key=>[:id]
      DateTime :created_at
      DateTime :updated_at

      primary_key [:id]

      index [:post_id]
      index [:user_id]
    end

    create_table(:comment_votes, :ignore_index_errors=>true) do
      String :id, :null=>false
      Integer :iid, :null=>false
      foreign_key :user_id, :users, :type=>String, :key=>[:id]
      foreign_key :comment_id, :comments, :type=>String, :key=>[:id]
      DateTime :created_at
      DateTime :updated_at

      primary_key [:id]

      index [:comment_id]
      index [:user_id]
    end
  end
end
