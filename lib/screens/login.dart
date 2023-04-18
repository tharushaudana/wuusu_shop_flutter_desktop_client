import 'package:flutter/material.dart';
import 'package:wuusu_shop_client/alert.dart';
import 'package:wuusu_shop_client/screens/home.dart';
import 'package:wuusu_shop_client/storage.dart';
import '../funcs.dart';
import '../apicall.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  ApiCall apiCall = ApiCall();
  Storage storage = Storage();

  String email = "";
  String password = "";

  bool isLogging = false;

  doLogin(BuildContext context) async {
    setState(() {
      isLogging = true;
    });

    /*apiCall.post("/login").data("email", email).data("password", password).on(
      success: (Map? data) async {
        await storage.save("token", data!["token"]);
        apiCall.setToken(data["token"]);
        openHomeScreen(context, data["user"]);
      },
      error: (String msg) {
        setState(() {
          isLogging = false;
        });
        Alert.show("Login failed", msg, context);
      },
    );*/

    try {
      Map? data = await apiCall
          .post("/login")
          .data("email", email)
          .data("password", password)
          .call();

      await storage.save("token", data!["token"]);
      apiCall.setToken(data["token"]);
      openHomeScreen(context, data["user"]);
    } catch (e) {
      setState(() {
        isLogging = false;
      });
      Alert.show("Login failed", e.toString(), context);
    }
  }

  openHomeScreen(BuildContext context, Map user) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) => HomeScreen(
          apiCall: this.apiCall,
          user: user,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xfffdc107),
              Colors.orange,
            ],
          ),
        ),
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              const Text(
                "Welcome Back!",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    width: 350,
                    height: 290,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha(100),
                    ),
                    child: isLogging
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                onChanged: (value) => setState(() {
                                  email = value;
                                }),
                                initialValue: email,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(3.0)),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blue,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(3.0),
                                    ),
                                  ),
                                  hintText: 'Enter your email here',
                                  labelText: 'Email',
                                  errorText: email.isEmpty
                                      ? "this field is required"
                                      : !Funcs.isValidEmail(email)
                                          ? "invalid email address"
                                          : null,
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              TextFormField(
                                onChanged: (value) => setState(() {
                                  password = value;
                                }),
                                initialValue: password,
                                obscureText: true,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(3.0),
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blue,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(3.0),
                                    ),
                                  ),
                                  hintText: 'Enter your password here',
                                  labelText: 'Password',
                                  errorText: password.isEmpty
                                      ? "this field is required"
                                      : null,
                                ),
                              ),
                              const Spacer(),
                              FilledButton(
                                onPressed: password.isNotEmpty &&
                                        Funcs.isValidEmail(email)
                                    ? () {
                                        doLogin(context);
                                      }
                                    : null,
                                child: Text("Login"),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const Text(
                "WUUSU FASHION CTEC",
                style: TextStyle(fontSize: 10),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
