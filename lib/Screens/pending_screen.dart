import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pet_match/Constants/global_variables.dart';
import 'package:provider/provider.dart';
import '../Services/firebase_services.dart';
import '../Widgets/login_button.dart';
import 'login_page.dart';

class PendingScreen extends StatelessWidget {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<GlobalVariables>().user;
    String pendingRequest =
        "You have requested to be admin for Pet Match and Your request is pending. You will be approved soon";
    String declined =
        "You have requested to be admin and unfortunately Your request has been declined, Sorry!";
    String blocked =
        "You have been permanently restricted from using Pet Match, Inconvenience caused is deeply regretted!";

    String adminRequest =
        "Your request to become admin has been approved. You can now use Pet Match Admin. You cannot use Pet Match anymore.";
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                user.type == 'requested'
                    ? pendingRequest
                    : user.type == 'declined'
                        ? declined
                        : user.type == 'blocked'
                            ? blocked
                            : adminRequest,
                textAlign: TextAlign.center,
              ),
            ),
            user.type == 'declined'
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: LoginButton(
                      onTap: () {
                        context
                            .read<GlobalVariables>()
                            .updateUserType(newType: 'requested');
                      },
                      child: const Text(
                        "Request Again",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                : const SizedBox()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await FirebaseServices.updateActiveStatus(false);
          await FirebaseServices.auth.signOut();
          await GoogleSignIn().signOut();
          context.read<GlobalVariables>().emptyRestriction();
          GlobalVariables.getCategories();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        },
        label: const Row(
          children: [
            Icon(Icons.logout),
            SizedBox(
              width: 10,
            ),
            Text("Logout")
          ],
        ),
      ),
    );
  }
}
