require 'dotenv/load'
require 'pdf-reader'
require 'csv'
require "ruby/openai"
# require "pycall/import"
# include PyCall::Import

file_name = ARGV[0]
reader = PDF::Reader.new(file_name)

DOC_EMBEDDINGS_MODEL = "text-search-curie-doc-001"

$openai_client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))

# PyCall.pyfrom("transformers", import: "GPT2TokenizerFast")
# tokenizer = PyCall::GPT2TokenizerFast.from_pretrained("gpt2")

# count tokens using tokenizer
def count_tokens(text)
  # return tokenizer.encode(text).length
  return text.split.length
end

def extract_pages(page_text, index)
  if page_text.length == 0
    return []
  end

  content = page_text.split.join(" ")
  outputs = [["Page " + index.to_s, content, count_tokens(content)+4]]
  return outputs
end

# use openai api to get embedding
def get_embedding(text)
  result = $openai_client.embeddings(
    parameters: {
      model: DOC_EMBEDDINGS_MODEL,
      input: text
    }
  )
  return result['data'][0]['embedding']
end

page_data = []
i = 1;

reader.pages.each do |page|
  page_data += extract_pages(page.text, i)
  i += 1
end


CSV.open("#{file_name}.pages.csv", "w") do |csv|
  csv << ["title", "content", "tokens"]
  page_data.each do |page|
    csv << page
  end
end

CSV.open("#{$file_name}.embeddings.csv", "w") do |csv|
  csv << ["title"] + (0..4095).to_a
  page_data.each_with_index do |page, idx|
    embedding = get_embedding(page[1])
    csv << ["Page #{idx + 1}"] + embedding
  end
end
