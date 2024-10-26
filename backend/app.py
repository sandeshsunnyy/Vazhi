from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import google.generativeai as genai

app = FastAPI()

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins (for development, adjust as needed)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

genai.configure(api_key="") 
model = genai.GenerativeModel("gemini-1.5-flash")

# Define request and response models
class UserDetails(BaseModel):
    gender: str
    age: int
    current_activity: str
    interests: str
    hobbies: str

class PredictionResponse(BaseModel):
    prediction: str
    tasks: list[str] = []  # Default to an empty list if tasks are not present

@app.post("/predict_future", response_model=PredictionResponse)
async def predict_future(details: UserDetails):
    try:
        # Call Gemini API with user details
        response = model.generate_content(
            f"Predict future for a person who is {details}. "
            f"Avoid markdown syntax, generate plain text also generate tasks for the user to achieve for the time period mentioned. "
            f"The task must be divided in a prioritized way. Daily tasks must be there."
        )

        # Check if the response contains an error
        if response is None or not hasattr(response, 'text'):
            return {"prediction": "Error generating prediction.", "tasks": []}

        prediction = response.text
        
        # Remove markdown formatting
        prediction = prediction.replace('* ', '').replace('**', '').replace('\n', ' ').strip()

        # Split tasks based on some criteria, ensure it returns a list
        tasks = prediction.split('.')  # Assuming tasks are separated by a period
        tasks = [task.strip() for task in tasks if task.strip()]  # Clean up the list

        return {"prediction": prediction, "tasks": tasks}
    except Exception as e:
        print(f"Error occurred: {e}")  # Log the error for debugging
        return {"prediction": "Error generating prediction.", "tasks": []}
