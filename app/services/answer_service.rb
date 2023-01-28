class AnswerService

  JSON_FILE = "static.json"  
  CONTEXT_FILE = Rails.root.join('book.pdf.pages.csv')
  EMBEDDING_FILE = Rails.root.join('book.pdf.embeddings.csv')
  COMPLETION_MODEL = "text-davinci-003"

  MAX_SECTION_LEN = 500
  SEPARATOR = "\n* "

  MODEL_NAME = "curie"
  DOC_EMBEDDINGS_MODEL = "text-search-#{MODEL_NAME}-doc-001"
  QUERY_EMBEDDINGS_MODEL = "text-search-#{MODEL_NAME}-query-001"

  def initialize
    @openai_client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
    @context = self.parse_context_csv
    @embedding = self.parse_embedding_csv
  end

  
  def get_answer(question)
    prompt, context = self.construct_promt(question)

    response = @openai_client.completions(
      parameters: {
        prompt: prompt,
        max_tokens: 150,
        temperature: 0,
        model: COMPLETION_MODEL,
      }
    )

    return {:success => false} if response['choices'].length == 0
    return {:success => true, :answer => response['choices'][0]['text'], :context => context}
  end

  private

  def get_relevant_context(question)
    most_relevant_document_sections = self.order_document_sections_by_query_similarity(question)
    chosen_sections_len = 0
    @chosen_sections = []

    most_relevant_document_sections.each do |key, index|
      document_section = @context[key]
      chosen_sections_len += document_section[:tokens].to_i + SEPARATOR.size
      if chosen_sections_len > MAX_SECTION_LEN
        space_left = MAX_SECTION_LEN - chosen_sections_len - SEPARATOR.size
        @chosen_sections << SEPARATOR + document_section[:content][...space_left]
        break
      end
      @chosen_sections << SEPARATOR + document_section[:content]
    end
    return @chosen_sections
  end

  def order_document_sections_by_query_similarity(question)
    query_embedding = self.get_embedding(question)
    scores = {}
    @embedding.each do |title, embedding|
      scores[title] = self.cosine_similarity(query_embedding, embedding)
    end
    sorted_scores = scores.sort_by { |title, score| score }.reverse.to_h
  end

  def cosine_similarity(a, b)
    """
    Calculate the cosine similarity between two vectors.
    """
    dot_product = a.zip(b).map { |x, y| x * y }.reduce(:+)
    magnitude_a = Math.sqrt(a.map { |x| x**2 }.reduce(:+))
    magnitude_b = Math.sqrt(b.map { |x| x**2 }.reduce(:+))
    return dot_product / (magnitude_a * magnitude_b)
  end

  def get_embedding(text)
    result = @openai_client.embeddings(
      parameters: {
        model: DOC_EMBEDDINGS_MODEL,
        input: text
      } 
    )
    return result['data'][0]['embedding']
  end

  def construct_promt(question)
    json = JSON.parse(File.read(JSON_FILE))
    header = json["header"]
    questions_and_answers = json["questions_and_answers"].join(" ")
    relevant_context = self.get_relevant_context(question).join(" ")

    preamble = header + relevant_context + questions_and_answers + "\n\n\nQ: " + question + "\n\nA: "

    return preamble, relevant_context

  end

  def parse_context_csv
    context = {}
    rows = CSV.read(CONTEXT_FILE, headers: true)
    rows[1..].each_with_index do |row, i|
      context[row["title"]] = {
        "content": row["content"],
        "tokens": row["tokens"],
      }
    end
    return context
  end

  def parse_embedding_csv
    embedding = {}
    rows = CSV.read(EMBEDDING_FILE, headers: true)
    rows[1..].each_with_index do |row, i|
      embedding[row[0]] = row[1..].map(&:to_f)
    end
    return embedding
  end

end