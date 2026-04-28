import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// ======================================================
/// PROFIEL INSTELLINGEN SCHERM
/// ------------------------------------------------------
/// Dit scherm laat gebruiker toe om:
/// - Persoonlijke gegevens te beheren
/// - Bedrijfsaccount te activeren
/// - Bedrijfsgegevens op te slaan
/// - Adresgegevens in te vullen
/// ======================================================

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

/// ======================================================
/// STATE CLASS
/// Bevat alle logica, controllers en UI state
/// ======================================================

class _ProfileSettingsScreenState
    extends State<ProfileSettingsScreen> {

  /// Hoofdkleur van knoppen / accenten
  static const Color primaryGreen =
  Color(0xFF2E7D32);

  /// Huidig ingelogde gebruiker
  final User? currentUser =
      FirebaseAuth.instance.currentUser;

  /// UI status
  bool isLoading = true;
  bool isSaving = false;
  bool isBusiness = false;
  bool usernameLocked = true;

  // ======================================================
  // CONTROLLERS PERSOONLIJKE GEGEVENS
  // ======================================================

  final firstNameController =
  TextEditingController();

  final lastNameController =
  TextEditingController();

  final usernameController =
  TextEditingController();

  final emailController =
  TextEditingController();

  final phoneController =
  TextEditingController();

  // ======================================================
  // CONTROLLERS BEDRIJF
  // ======================================================

  final companyNameController =
  TextEditingController();

  final vatNumberController =
  TextEditingController();

  final websiteController =
  TextEditingController();

  // ======================================================
  // CONTROLLERS ADRES
  // ======================================================

  final streetController =
  TextEditingController();

  final houseNumberController =
  TextEditingController();

  final boxNumberController =
  TextEditingController();

  final postalCodeController =
  TextEditingController();

  final cityController =
  TextEditingController();

  /// ======================================================
  /// SCREEN START
  /// Wordt 1x uitgevoerd bij openen scherm
  /// ======================================================

  @override
  void initState() {
    super.initState();

    /// Profielgegevens ophalen uit Firestore
    loadProfileData();
  }

  /// ======================================================
  /// MEMORY OPRUIMEN
  /// Controllers vernietigen bij sluiten scherm
  /// ======================================================

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();

    companyNameController.dispose();
    vatNumberController.dispose();
    websiteController.dispose();

    streetController.dispose();
    houseNumberController.dispose();
    boxNumberController.dispose();
    postalCodeController.dispose();
    cityController.dispose();

    super.dispose();
  }

  /// ======================================================
  /// DATA OPHALEN UIT FIRESTORE
  /// ======================================================

  Future<void> loadProfileData() async {
    if (currentUser == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser!.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;

      /// Persoonlijk
      firstNameController.text =
          data["firstName"] ?? "";

      lastNameController.text =
          data["lastName"] ?? "";

      usernameController.text =
          data["username"] ?? "";

      emailController.text =
          data["email"] ?? "";

      phoneController.text =
          data["phone"] ?? "";

      /// Bedrijf
      isBusiness =
          data["isBusiness"] ?? false;

      companyNameController.text =
          data["companyName"] ?? "";

      vatNumberController.text =
          data["vatNumber"] ?? "";

      websiteController.text =
          data["website"] ?? "";

      /// Adres
      streetController.text =
          data["street"] ?? "";

      houseNumberController.text =
          data["houseNumber"] ?? "";

      boxNumberController.text =
          data["boxNumber"] ?? "";

      postalCodeController.text =
          data["postalCode"] ?? "";

      cityController.text =
          data["city"] ?? "";

      /// Username mag niet meer aangepast worden
      usernameLocked =
          usernameController.text
              .trim()
              .isNotEmpty;
    }

    setState(() {
      isLoading = false;
    });
  }

  /// ======================================================
  /// OPSLAAN NAAR FIRESTORE
  /// ======================================================

  Future<void> saveProfile() async {
    if (currentUser == null) return;

    /// Verplichte velden controleren
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        usernameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      showMessage(
          "Vul alle verplichte velden in.");
      return;
    }

    /// Bedrijfscontrole
    if (isBusiness &&
        (companyNameController.text
            .trim()
            .isEmpty ||
            vatNumberController.text
                .trim()
                .isEmpty)) {
      showMessage(
          "Vul alle bedrijfsgegevens in.");
      return;
    }

    setState(() {
      isSaving = true;
    });

    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser!.uid)
        .set({
      /// Persoonlijk
      "firstName":
      firstNameController.text.trim(),

      "lastName":
      lastNameController.text.trim(),

      "username":
      usernameController.text
          .trim()
          .toLowerCase(),

      "email":
      emailController.text.trim(),

      "phone":
      phoneController.text.trim(),

      /// Bedrijf
      "isBusiness": isBusiness,

      "companyName":
      companyNameController.text.trim(),

      "vatNumber":
      vatNumberController.text.trim(),

      "website":
      websiteController.text.trim(),

      /// Adres
      "street":
      streetController.text.trim(),

      "houseNumber":
      houseNumberController.text.trim(),

      "boxNumber":
      boxNumberController.text.trim(),

      "postalCode":
      postalCodeController.text.trim(),

      "city":
      cityController.text.trim(),

      /// Laatste update
      "updatedAt":
      FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    setState(() {
      isSaving = false;
      usernameLocked = true;
    });

    showMessage(
        "Profiel succesvol opgeslagen");

    Navigator.pop(context);
  }

  /// ======================================================
  /// SNACKBAR MELDING
  /// ======================================================

  void showMessage(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  /// ======================================================
  /// HERBRUIKBAAR INPUTVELD
  /// ======================================================

  Widget buildInput({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
    TextInputType keyboardType =
        TextInputType.text,
  }) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  /// ======================================================
  /// TITEL BOVEN SECTIES
  /// ======================================================

  Widget buildTitle(String text) {
    return Padding(
      padding:
      const EdgeInsets.only(
        top: 20,
        bottom: 10,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight:
          FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    /// Loading scherm tijdens ophalen Firestore data
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        title: const Text(
          "Profielinstellingen",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,

          children: [

            // ==================================================
            // PERSOONLIJKE GEGEVENS
            // ==================================================

            buildTitle("Persoonlijke gegevens"),

            buildInput(
              controller: firstNameController,
              label: "Voornaam",
            ),

            buildInput(
              controller: lastNameController,
              label: "Achternaam",
            ),

            buildInput(
              controller: usernameController,
              label: "Gebruikersnaam",
              enabled: !usernameLocked,
            ),

            if (usernameLocked)
              Padding(
                padding:
                const EdgeInsets.only(
                  bottom: 16,
                ),
                child: Text(
                  "Gebruikersnaam kan niet meer gewijzigd worden.",
                  style: TextStyle(
                    color:
                    Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ),

            buildInput(
              controller: emailController,
              label: "E-mail",
              keyboardType:
              TextInputType.emailAddress,
            ),

            buildInput(
              controller: phoneController,
              label: "Gsm nummer",
              keyboardType:
              TextInputType.phone,
            ),

            // ==================================================
            // ACCOUNT TYPE
            // ==================================================

            buildTitle("Accounttype"),

            SwitchListTile(
              value: isBusiness,
              activeThumbColor: primaryGreen,
              title: const Text(
                "Bedrijfsaccount",
              ),
              subtitle: Text(
                isBusiness
                    ? "Je account staat als bedrijf ingesteld"
                    : "Schakel in om als bedrijf te verhuren",
              ),
              onChanged: (value) {
                setState(() {
                  isBusiness = value;
                });
              },
            ),

            // ==================================================
            // BEDRIJF
            // ==================================================

            if (isBusiness) ...[
              buildTitle("Bedrijf"),

              buildInput(
                controller:
                companyNameController,
                label: "Bedrijfsnaam",
              ),

              buildInput(
                controller:
                vatNumberController,
                label: "BTW nummer",
              ),

              buildInput(
                controller:
                websiteController,
                label: "Website",
              ),

              // ==============================================
              // ADRES
              // ==============================================

              buildTitle("Adres"),

              buildInput(
                controller:
                streetController,
                label: "Straatnaam",
              ),

              Row(
                children: [

                  Expanded(
                    child: buildInput(
                      controller:
                      houseNumberController,
                      label:
                      "Huisnummer",
                    ),
                  ),

                  const SizedBox(
                      width: 12),

                  Expanded(
                    child: buildInput(
                      controller:
                      boxNumberController,
                      label:
                      "Busnummer",
                    ),
                  ),
                ],
              ),

              Row(
                children: [

                  Expanded(
                    flex: 2,
                    child: buildInput(
                      controller:
                      postalCodeController,
                      label:
                      "Postcode",
                    ),
                  ),

                  const SizedBox(
                      width: 12),

                  Expanded(
                    flex: 4,
                    child: buildInput(
                      controller:
                      cityController,
                      label:
                      "Plaatsnaam",
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 30),

            // ==================================================
            // OPSLAAN
            // ==================================================

            SizedBox(
              height: 55,

              child: ElevatedButton(
                onPressed: isSaving
                    ? null
                    : saveProfile,

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  primaryGreen,
                  foregroundColor:
                  Colors.white,
                ),

                child: isSaving
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child:
                  CircularProgressIndicator(
                    color:
                    Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  "Opslaan",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }}