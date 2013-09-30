namespace :brisk do
  task :activator => :app do
    admin = User.first!(admin: true, handle: 'maccaw')
    users = User.pending.ordered
    users = users.where(~:email => nil)
    users = users.where {|u| u.created_at >= 1.day.ago }

    users.each do |user|
      puts '----------------------'
      puts "ID:      #{user.id}"
      puts "Name:    #{user.name}"
      puts "Handle:  #{user.handle}"
      puts "Twitter: #{user.twitter}"
      puts "GitHub:  #{user.github}"
      puts "About:   #{user.about}"
      puts "URL:     #{user.url}"

      puts
      puts "Activate user? (y/n)"
      answer = STDIN.gets.chomp.downcase

      if answer == 'y'
        invite = UserInvite.new(
          email:   user.email,
          twitter: user.twitter,
          github:  user.github
        )
        invite.user = admin
        invite.save!

        user.activate!(invite)
        user.notify_activate!
      end
    end

    puts "\nThat's all!"
  end

  task :activate_ids => :app do
    admin = User.first!(admin: true, handle: 'maccaw')

    puts 'Enter User IDs:'

    input = ''
    while line = STDIN.gets
      break if line == "\n"
      input += line
    end

    ids   = input.chomp.split("\n")
    users = User.pending.where(id: ids).all

    puts "Activate IDs? (y/n)\n\t#{users.map(&:id).join("\n\t")}"

    answer = STDIN.gets.chomp.downcase
    abort unless answer == 'y'

    users.each do |user|
      invite = UserInvite.new(
        email:   user.email,
        twitter: user.twitter,
        github:  user.github
      )
      invite.user = admin
      invite.save!

      user.activate!(invite)
      user.notify_activate!
    end

    puts "\nThat's all!"
  end
end