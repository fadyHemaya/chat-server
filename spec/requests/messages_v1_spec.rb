require 'rails_helper'

RSpec.describe "MessagesV1s", type: :request do
	context '#index' do
		let!(:url) { '/api/v1/messages' }

		context 'When there are no messages' do 
			let!(:expected_response){{data: []}}

			it 'should return an empty array' do
				get url 
				expect(response.status).to eq 200
				expect(JSON.parse(response.body)['data']).to eq expected_response[:data]
			end
		end
		context 'When there are some messages created' do
			before do
				App.create(name: "App1", token:"a1234")
				App.create(name: "App2", token:"b1234")
				Chat.create(app_token: "a1234", number:1)
				Chat.create(app_token: "b1234", number:1)
        Message.create(chat_id: Chat.first.id, body: "hey there", number: 1)
        Message.create(chat_id: Chat.second.id, body: "hey there", number: 1)
			end

			let!(:expected_response) do
				JSON.parse(File.read("#{Rails.root}/spec/fixtures/messages/message_data.json"))
			end

			it 'should return an array of all created records' do
				get url
				expect(response.status).to eq 200
				expect(response.body).to eq expected_response.to_json
			end
		end
	end

	context '#show' do
		let!(:token) { "b1234" }
		let!(:chat_number) { 1 }
		let!(:url) { "/api/v1/applications/#{token}/chats/#{chat_number}/messages" }
		context 'When requesting messages of non valid chat' do 
			let!(:expected_response){"No Chat Found"}
			before do
				App.create(name: "App1", token:"a1234")
			end

			it 'should return chat not found' do
				get url 
				expect(response.status).to eq 404
				expect(JSON.parse(response.body)['data']).to eq expected_response
			end
		end
		context 'When requesting a valid chat with no messages' do
			before do
				App.create(name: "App1", token:"b1234")
				Chat.create(app_token: "b1234", number:1)
			end
			it 'should return empty list of chats' do
				get url
				expect(response.status).to eq 200
				expect(JSON.parse(response.body)['data']).to eq []
			end
		end
		context 'When requesting a valid token with created chats' do
			let!(:expected_response) do
				JSON.parse(File.read("#{Rails.root}/spec/fixtures/messages/message_data_show.json"))
			end
			before do
				App.create(name: "App2", token:"b1234")
				Chat.create(app_token: "b1234", number:1)
				Chat.create(app_token: "b1234", number:2)
        Message.create(chat_id: Chat.first.id, body: "hey there", number: 1)
        Message.create(chat_id: Chat.first.id, body: "hello", number: 2)
        Message.create(chat_id: Chat.second.id, body: "hello", number: 1)
			end				
			it 'should return correct data of created messages of specific chat' do
				get url
				expect(response.status).to eq 200
				expect(response.body).to eq expected_response.to_json
			end
		end
	end

	context '#create' do
		context 'When creating with non valid chat' do 
      let!(:token) { "c1234" }
      let!(:chat_number) { 1 }
      let!(:url) { "/api/v1/applications/#{token}/chats/#{chat_number}/messages" }
			before do
				App.create(name: "App1", token:"a1234")
				Chat.create(app_token: "a1234", number:1)
			end	
			it 'should return chat not found response' do
				post url, params: {message: {body: "random text"}}
				expect(response.status).to eq 404
				expect(JSON.parse(response.body)['data']).to eq "No Chat Found"
			end
			it 'should not change the count' do
				post url, params: {message: {body: "random text"}}
				expect( Message.count).to eq 0
			end
		end

    context 'When creating with empty message body' do 
      let!(:token) { "c1234" }
      let!(:chat_number) { 1 }
      let!(:url) { "/api/v1/applications/#{token}/chats/#{chat_number}/messages" }
			before do
        App.create(name: "App1", token:"a1234")
				Chat.create(app_token: "a1234", number:1)
			end
			it 'raise a unprocessable entity error with null value' do
        post url, params: {message: {body: nil}}
				expect(response.status).to eq 422
				expect(JSON.parse(response.body)['error']).to eq "Invalid Message Body"
			end
			it 'raise a unprocessable entity error with empty value' do
        post url, params: {message: {body: ""}}
				expect(response.status).to eq 422
				expect(JSON.parse(response.body)['error']).to eq "Invalid Message Body"
			end
		end

		context 'When creating with valid chat' do
      let!(:params){{message: {body: "random text"}}}
			before do
				post "/api/v1/applications", params: {app: {name: "random name"}}
				post "/api/v1/applications/#{App.first.token}/chats"
        ChatsCreatorJob.drain   
			end
			it 'should return correct value of created messages' do  
				post "/api/v1/applications/#{App.first.token}/chats/1/messages", params: params
				expect(response.status).to eq 200
				expect(JSON.parse(response.body)['data']['number']).to eq 1
				expect(JSON.parse(response.body)['data']['body']).to eq params[:message][:body]
			end
      it 'should enqueue a job in the messages creator queue' do
				expect { 	post "/api/v1/applications/#{App.first.token}/chats/1/messages", params: params }.to change(
				  Sidekiq::Queues['messages-creator'], :size
				).by(1)
			end	
		end

		context 'When creating multiple message for same chat' do
      let!(:params){{message: {body: "random text"}}}
			before do
				post "/api/v1/applications", params: {app: {name: "random name"}}
				post "/api/v1/applications/#{App.first.token}/chats"
        ChatsCreatorJob.drain   
			end
			it 'should create the messsages with incremental message number' do  
				post "/api/v1/applications/#{App.first.token}/chats/1/messages", params: params
				post "/api/v1/applications/#{App.first.token}/chats/1/messages", params: params
				expect(response.status).to eq 200
				expect(JSON.parse(response.body)['data']['number']).to eq 2
			end
		end
	end

  context '#search' do
  
  let!(:token) { "a1234" }
  let!(:chat_number) { 1 }
  let!(:url) { "/api/v1/applications/#{token}/chats/#{chat_number}/messages/search" }
  context 'When no messages are created' do 
    before do
      App.create(name: "App1", token:"a1234")
      Chat.create(app_token: "a1234", number:1)
    end	
    it 'should return empty list' do
      post url, params: {message: {body: "hi"}}
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']).to eq []
    end
  end

  context 'When searching with non valid chat' do
    let!(:params){{message: {body: "random text"}}}
    before do
      App.create(name: "App1", token:"b1234")
      Chat.create(app_token: "b1234", number:1) 
      Message.create(chat_id:Chat.first.id, body:"random text") 
    end
    it 'should return chat not found response' do
      post url, params: {message: {body: "hi" }}
      expect(response.status).to eq 404
      expect(JSON.parse(response.body)['data']).to eq "No Chat Found"
    end
  end

  context 'When searching with valid chat but no message match query' do
    let!(:params){{message: {body: "random text"}}}
    before do
      App.create(name: "App1", token:"a1234")
      Chat.create(app_token: "a1234", number:1) 
      Message.create(chat_id:Chat.first.id, body:"random text") 
    end
    it 'should return empty list of messages' do
      post url, params: {message: {body: "hi" }}
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data']).to eq []
    end
  end
  context 'When searching with valid chat and messages match query' do
    let!(:params){{message: {body: "random text"}}}
    before do
      App.create(name: "App1", token:"a1234")
      post "/api/v1/applications/#{App.first.token}/chats"
      ChatsCreatorJob.drain   
			post "/api/v1/applications/#{App.first.token}/chats/#{Chat.first.number}/messages", params: {message:{body:"hello, hi Fady"}}
			post "/api/v1/applications/#{App.first.token}/chats/#{Chat.first.number}/messages", params: {message:{body:"hi there"}}
			post "/api/v1/applications/#{App.first.token}/chats/#{Chat.first.number}/messages", params: {message:{body:"random text"}}
      MessagesCreatorJob.drain 
      sleep 2
    end
    it 'should return all messages that partially match the query' do
      post  "/api/v1/applications/#{App.first.token}/chats/#{Chat.first.number}/messages/search", params: {message: {body: "hi"}}
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['data'].count).to eq 2
      expect(JSON.parse(response.body)['data'][0]["body"]).to eq "hi there"
      expect(JSON.parse(response.body)['data'][1]["body"]).to eq "hello, hi Fady"
    end
  end
end
end
