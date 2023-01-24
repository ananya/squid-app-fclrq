import React, {useState} from "react";
import { Link } from "react-router-dom";
import content from "../../../static.json";


const Home = () => {
  const [question, setQuestion] = useState(content.default_question)

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log("submitting");
    setQuestion(question);
  }

  return (
    <div className="container">
      <div className="flex flex-col justify-center item-center">
        <div className="flex justify-center">
          <a href = {content.book_url}>
            <img 
              src={content.book_image} 
              className="w-1/2 p-5"
              loading="lazy" />
          </a>
        </div>
        <h1 className="text-center">{content.book_title}</h1>
        <p className="text-center">{content.landing_description}</p>

        <div className="flex justify-center">
          <form onSubmit={handleSubmit} className="flex flex-col justify-center">
            <textarea
              name="question"
              id="question"
              className="shadow-md"
              placeholder="Ask a question"
              value={question}  
              onChange={e => setQuestion(e.target.value)}
            />
            <button type="submit" className="bg-black text-white">
              Ask question
            </button>
          </form>
        </div>
      </div>
    </div>

  );
};

export default Home