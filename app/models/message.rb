class Message < ApplicationRecord
  belongs_to :chat

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  es_index_settings = {
    'analysis': {
      'filter': {
        'trigrams_filter': {
          'type':'ngram',
          'min_gram': 3,
          'max_gram': 3
        }
      },
      'analyzer': {
        'trigrams': {
          'type': 'custom',
          'tokenizer': 'standard',
          'filter': [
            'lowercase',
            'trigrams_filter'
          ]
        }
      }
    }
  }

  settings es_index_settings do
    mapping do
      indexes :body, type: 'string', analyzer: 'trigrams'
    end
  end

  def self.search(query)
    __elasticsearch__.search(
    {
      query: {
          match: {
            body: query,
          }
        },
    }).records
  end
end
