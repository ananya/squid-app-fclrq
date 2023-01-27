import React, { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import content from "../../../static.json";
import axios from 'axios'



const Home = () => {
  const [question, setQuestion] = useState(content.default_question);
  const [answer, setAnswer] = useState(null);
  
  const [questionSubmitter, setQuestionSubmitter] = useState(null);

  const handleQuestionSubmit = (e) => {
    e.preventDefault();
    console.log("question", question, e);
    setQuestion(question);
    setQuestionSubmitter(true);
  }

  const handleLuckySubmit = (e) => {
    e.preventDefault();
    console.log("lucky");
  }

  useEffect(() => {
    if(questionSubmitter) {
      askQuestion().then((answer) => {
        setAnswer(answer);
        setQuestionSubmitter(false);
      })
    }
  }, [questionSubmitter])


  const askQuestion = async () => {
    try {
      const response = await axios.post("/questions/ask", { question: question });
      console.log(response);
      return response.data.answer;
    } catch (error) {
      console.log(error);
      return Promise.reject(error);
    }
  }

  return (
    <div className="flex flex-col items-center min-h-screen mx-auto max-w-xl p-8">
      <div className="flex m-8 justify-center items-center">
        <a href={content.book_url}>
          <img
            src={content.book_image}
            className="w-1/2 text-center rounded-md shadow-md m-auto"
            loading="lazy" />
        </a>
      </div>
      <h1 className="font-bold text-2xl" >{content.book_title}</h1>
      <p className="my-4 text-slate-500 text-lg">{content.landing_description}</p>

      <form className="justify-center items-center w-full">
        <textarea
          name="question"
          id="question"
          className="w-full box-border border-solid border-black border rounded-lg text-lg px-3 py-2"
          placeholder="Ask a question"
          value={question}
          onChange={e => setQuestion(e.target.value)}
        />
        <div className="flex justify-center gap-4">
          <button
            className="bg-black text-white mt-4 w-auto py-2 px-5 rounded-lg"
            onClick={handleQuestionSubmit}
          >
            Ask question
          </button>

          <button
            className="bg-slate-200 mt-4 w-auto py-2 px-5 rounded-lg"
            onClick={handleLuckySubmit}
          >
            I'm Feeling Lucky
          </button>
        </div>
      </form>
      {answer && (
        <div className="mt-8">
          <h2 className="font-bold text-2xl" >{answer}</h2>
        </div>
      )}
    </div>
  );
};

export default Home