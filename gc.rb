require 'httparty'
require 'open-uri'
require 'hashie/mash'
require 'json'
require 'zip'

class GatherContentApi
  include HTTParty
  format :json
  debug_output $stdout

  def initialize(subdomain, u, p)
    self.class.base_uri('https://' + subdomain + '.gathercontent.com/api/0.3')
    @auth = {:username => u, :password => p}
  end

  def method_missing(method, *args, &block)
    options = {:body => {'id' => args[0]}, :digest_auth => @auth}
    self.class.post('/' + method.to_s, options)
  end

  def create_hash(m)
    by_id = m.group_by(&:id)
    page_hash = m.group_by { |page| by_id[page.parent_id]}
  end

end


api = GatherContentApi.new('organization', 'api_key', 'x') #set ENV variable for API key
mash = Hashie::Mash.new(api.get_pages_by_project('project_id')) #replace with project_id
mash.shift
hashies = mash.first[1]

list = []

### Useless procedural crap ###

#by_id = hashies.group_by(&:id)
#page_hash = hashies.group_by { |page| by_id[page.parent_id] }
page_hash = GatherContentApi.create_hash(hashies)
puts page_hash
#page_hash.each do |k,v|
#  if k != nil
#    v.each do |write|
#      puts "writing #{write.name}"
#      if Dir["/Users/stuartillson/ruby_projects/gctest/#{k[0]}/#{write.name}"].empty?
#        Dir.mkdir "/Users/stuartillson/ruby_projects/gctest/#{k[0].name}/#{write.name}"
#      end
#      image = Hashie::Mash.new(api.get_files_by_page(write.id))
#      image.shift
#      if image.error?
#        break
#      else
#        list.push(image.first[1])
#      end
#      list.flatten.each do |i|
#        if i.page_id == write.id
#          open("/Users/stuartillson/ruby_projects/gctest/#{k[0].name}/#{write.name}/#{i.original_filename}", 'wb') do |file|
#            file << open("https://gathercontent.s3.amazonaws.com/#{i.filename}").read
#          end
#        end
#      end
#    end
#  end
#end
 #   if k.nil?
 #     v.each do |write|
 #       puts "writing #{write.name}"
 ##       if Dir["/Users/stuartillson/ruby_projects/gctest/#{write.name}"].empty?
 #         Dir.mkdir "/Users/stuartillson/ruby_projects/gctest/#{write.name}"
 #       end
 #       image = Hashie::Mash.new(api.get_files_by_page(write.id))
 #       image.shift
 ##       if image.error?
 #         break
 #       else
 #         list.push(image.first[1])
 #       end
 #       list.flatten.each do |i|
 #         if i.page_id == write.id
 #           open("/Users/stuartillson/ruby_projects/gctest/#{write.name}/#{i.original_filename}", 'wb') do |file|
 #             file << open("https://gathercontent.s3.amazonaws.com/#{i.filename}").read
 #           end
 #         end
 #       end
 #     end
 #   end
 # end


#page_hash = Hash[hashies.map {|page| if page.parent_id != "0" then [page.id, page] else [page.parent_id, page] end}]



