<img width="1280" alt="readme-banner" src="https://github.com/user-attachments/assets/35332e92-44cb-425b-9dff-27bcf1023c6c">


# VAZHI 🎯

## Basic Details

### Team Name: Wayne Enterprise

### Team Members

- Member 1: [Sandesh Varghese Sunny] - [Viswajyothi College of Engineering and Technology Vazhakulam]
- Member 2: [Rickson Raphel] - [Viswajyothi College of Engineering and Technology Vazhakulam]

### Project Description
VAZHI is an innovative mobile application designed to predict future outcomes based on users' personal preferences, including their likes, dislikes, and goals. By collecting user data, the app generates tailored predictions and action plans to help users achieve their dreams in various areas, including career and fitness.

### The Problem (that doesn't exist)
Are you tired of living aimlessly and want to know what your future looks like? Do you feel overwhelmed by choices and need someone (or something) to guide you? VAZHI solves the "ridiculous" problem of not knowing how to align your life with your dreams!

### The Solution (that nobody asked for)
Our solution is a friendly AI that takes your personal details and predicts your future, providing daily tasks to guide you toward your goals. Whether you want to become a software developer at Google or just get fit, VAZHI is your ultimate life coach!

## Technical Details

### Technologies/Components Used

For Software:
- **Languages used:** Dart, Python
- **Frameworks used:** Flutter
- **Libraries used:** http, json_serializable, Pydantic, google-generativeai, uvicorn
- **Tools used:** Visual Studio Code, FastAPI, Docker

For Hardware:
- Not applicable for this project (Mobile Application).

### Implementation

#### For Software:
##### Installation
To install the project, run the following commands in your terminal:

```bash
flutter pub get
```

##### Run
To run the application, use:

```bash
flutter run
```

### Project Documentation

#### For Software:

##### Screenshots
![Screenshot1](screenshot1.png)
![Screenshot1](https://github.com/user-attachments/assets/39c9485f-602d-4b38-9435-41c749a74806)

*This screenshot shows the splash screen of the VAZHI app, welcoming users.*


![Screenshot2](https://github.com/user-attachments/assets/706ede90-694e-482f-8732-cb4162da6512)

*This screenshot illustrates the user details input page, where users can provide personal information.*

![Screenshot3](screenshot3.png)
![Screenshot3](https://github.com/user-attachments/assets/8dca406b-c20e-405b-8084-e8bca3063091)

*This screenshot displays the prediction results page, showing the user's future prediction and tasks.*


#### Code Explanation

Here are some key code snippets and their explanations:

1. **Main Application Entry Point**
   ```dart
   void main() {
     runApp(MyApp());
   }
   ```
   - This function initializes the Flutter app by calling `runApp`, which takes the `MyApp` widget as an argument.

2. **MyApp Widget**
   ```dart
   class MyApp extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return MaterialApp(
         title: 'VAZHI',
         theme: ThemeData(
           primarySwatch: Colors.blue,
         ),
         home: SplashScreen(),
       );
     }
   }
   ```
   - This widget sets up the application with a title and a theme. The home screen is set to `SplashScreen`, which is displayed when the app launches.

3. **Splash Screen with Animation**
   ```dart
   class SplashScreen extends StatefulWidget {
     @override
     _SplashScreenState createState() => _SplashScreenState();
   }

   class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
     late AnimationController _controller;
     late Animation<double> _opacityAnimation;

     @override
     void initState() {
       super.initState();
       _controller = AnimationController(
         vsync: this,
         duration: Duration(seconds: 3),
       );
       _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
       _controller.forward();
       Timer(Duration(seconds: 3), () {
         Navigator.of(context).pushReplacement(
           MaterialPageRoute(builder: (context) => UserDetailsPage()),
         );
       });
     }
   }
   ```
   - This code creates a splash screen with a fade-in animation. The `AnimationController` and `Tween` are used to control the opacity of the text. After 3 seconds, the app navigates to the `UserDetailsPage`.

4. **User Details Input Page**
   ```dart
   class UserDetailsPage extends StatelessWidget {
     final TextEditingController nameController = TextEditingController();
     final TextEditingController genderController = TextEditingController();
     // Additional controllers...

     void navigateToDreamJob(BuildContext context) {
       Navigator.push(
         context,
         MaterialPageRoute(
           builder: (context) => DreamJobPage(
             name: nameController.text,
             gender: genderController.text,
             age: int.tryParse(ageController.text) ?? 0,
             currentActivity: activityController.text,
             interests: interestsController.text,
             hobbies: hobbiesController.text,
             timePeriod: timePeriodController.text,
           ),
         ),
       );
     }

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(
           title: Text('User Details'),
         ),
         body: Padding(
           padding: const EdgeInsets.all(16.0),
           child: Column(
             children: [
               TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
               // Additional TextFields...
               ElevatedButton(
                 onPressed: () => navigateToDreamJob(context),
                 child: Text('Next'),
               ),
             ],
           ),
         ),
       );
     }
   }
   ```
   - This page collects user details through text fields. The `navigateToDreamJob` function takes the user input and passes it to the `DreamJobPage`.

5. **Dream Job Prediction**
   ```dart
   class DreamJobPage extends StatelessWidget {
     final String name;
     // Additional parameters...

     void predictFuture(BuildContext context) async {
       final response = await http.post(
         Uri.parse('http://10.0.2.2:8000/predict_future'),
         headers: <String, String>{
           'Content-Type': 'application/json; charset=UTF-8',
         },
         body: jsonEncode({
           'name': name,
           'gender': gender,
           // Additional fields...
         }),
       );

       if (response.statusCode == 200) {
         final data = jsonDecode(response.body);
         Navigator.push(
           context,
           MaterialPageRoute(
             builder: (context) => PredictionPage(
               prediction: data['prediction'],
               tasks: List<String>.from(data['tasks']),
             ),
           ),
         );
       } else {
         throw Exception('Failed to load prediction');
       }
     }
   }
   ```
   - This page takes user details and sends a POST request to a FastAPI server to predict the user's future and tasks based on the input. If successful, it navigates to the `PredictionPage` to display the results.

6. **FastAPI Server Implementation**
   ```python
   from fastapi import FastAPI
   from fastapi.middleware.cors import CORSMiddleware
   from pydantic import BaseModel
   import google.generativeai as genai

   app = FastAPI()
   app.add_middleware(
       CORSMiddleware,
       allow_origins=["*"],
       allow_credentials=True,
       allow_methods=["*"],
       allow_headers=["*"],
   )

   genai.configure(api_key="YOUR_API_KEY")  # Replace with your actual API key
   model = genai.GenerativeModel("gemini-1.5-flash")

   class UserDetails(BaseModel):
       gender: str
       age: int
       current_activity: str
       interests: str
       hobbies: str

   class PredictionResponse(BaseModel):
       prediction: str
       tasks: list[str] = []

   @app.post("/predict_future", response_model=PredictionResponse)
   async def predict_future(details: UserDetails):
       response = model.generate_content(f"Predict future for a person who is {details}.")
       prediction = response.text
       tasks = prediction.split('.')
       return {"prediction": prediction, "tasks": tasks}
   ```
   - This FastAPI server receives user details, interacts with the Google Generative AI model to generate predictions, and returns them as JSON. It uses CORS middleware to allow cross-origin requests from the Flutter app.

### Project Demo
#### Video
[https://drive.google.com/file/d/1tyPwMh75s4TXhmGTXvqYpRa4TtVuwaFN/view?usp=sharing]
*The video demonstrates how to use the VAZHI app, showcasing its features from start to finish.*



## Team Contributions
- [Rickson Raphel]: App architecture , U I and implementation of user input functionalities Testing, documentation, and deployment.
- [Sandesh Varghese Sunny]: Backend implementation using FastAPI and integration with Google Generative AI.

---

Made with ❤️ at TinkerHub Useless Projects 

![Static Badge](https://img.shields.io/badge/TinkerHub-24?color=%23000000&link=https%3A%2F%2Fwww.tinkerhub.org%2F)
![Static Badge](https://img.shields.io/badge/UselessProject--24-24?link=https%3A%2F%2Fwww.tinkerhub.org%2Fevents%2FQ2Q1TQKX6Q%2FUseless%2520Projects)
