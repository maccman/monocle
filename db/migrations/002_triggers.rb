Sequel.migration do
  change do
    pgt_counter_cache(
      :posts, :id, :comments_count,
      :comments, :post_id,
      :function_name => :cc_posts_comments_count
    )

    definition = <<-SQL
      BEGIN
        IF OLD.handle != NEW.handle THEN
          UPDATE "posts" SET "user_handle" = NEW.handle WHERE "user_id" = NEW.id;
        END IF;
        RETURN NEW;
      END;
    SQL

    create_function(
      :c_posts_user_handle, definition,
      :language=>:plpgsql, :returns =>
      :trigger, :replace => true)

    create_trigger(
      :users, :trg_posts_user_handle,
      :c_posts_user_handle, :events => [:update],
      :each_row => true)

    definition = <<-SQL
      BEGIN
        UPDATE "posts" SET voted_user_ids = array_append(voted_user_ids, NEW.user_id) WHERE "id" = NEW.post_id;
        RETURN NEW;
      END;
    SQL

    create_function(
      :c_posts_voted, definition, :language => :plpgsql,
      :returns => :trigger, :replace => true)

    create_trigger(
      :post_votes, :trg_posts_voted,
      :c_posts_voted, :events => [:insert],
      :each_row => true)
  end
end