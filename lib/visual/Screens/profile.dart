import 'dart:io';
import 'package:UgmaNet/services/user_service.dart';
import 'package:UgmaNet/visual/Screens/Home.dart';
import 'package:UgmaNet/visual/Screens/Loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/profile.dart';

class CreateProfileScreen extends StatelessWidget {
  CreateProfileScreen({super.key});

  final UserService _userService = UserServiceImpl.instance;

  @override
  Widget build(BuildContext context) {
    final future = _checkProfile();

    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoaderScreen();
          }

          if (!snapshot.hasData) {
            return const Scaffold(
              body: CreateProfileForm(),
            );
          }

          return const HomeScreen();
        });
  }

  Future<Profile?> _checkProfile() async {
    final user = await _userService.getCurrentUser();

    final profile = await _userService.getProfile(user!.uid);
    return profile;
  }
}

class CreateProfileForm extends StatefulWidget {
  const CreateProfileForm({super.key});

  @override
  State<StatefulWidget> createState() {
    return CreateProfileFormState();
  }
}

class CreateProfileFormState extends State<CreateProfileForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  final UserService _userService = UserServiceImpl.instance;

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FormBuilderTextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.alternate_email_rounded),
              labelText: 'Nombre de usuario',
              border: OutlineInputBorder(),
              helperText:
                  'Máximo 20 caracteres. Se permiten . o _. Sin espacios en blanco.',
            ),
            name: 'username',
            onChanged: (val) {},
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                  errorText: 'El campo es requerido'),
              FormBuilderValidators.username(
                  maxLength: 20,
                  allowUnderscore: true,
                  allowSpace: false,
                  allowNumbers: true,
                  allowDash: false,
                  allowSpecialChar: false,
                  allowDots: true,
                  errorText: 'No válido')
            ]),
          ),
          const SizedBox(
            height: 10,
          ),
          FormBuilderTextField(
            decoration: const InputDecoration(
              labelText: 'Nombre',
              border: OutlineInputBorder(),
            ),
            name: 'firstName',
            onChanged: (val) {},
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                  errorText: 'El campo es requerido'),
              FormBuilderValidators.firstName(errorText: 'No válido')
            ]),
          ),
          const SizedBox(
            height: 10,
          ),
          FormBuilderTextField(
            decoration: const InputDecoration(
              labelText: 'Apellido',
              border: OutlineInputBorder(),
            ),
            name: 'lastName',
            onChanged: (val) {},
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                  errorText: 'El campo es requerido'),
              FormBuilderValidators.lastName(errorText: 'No válido')
            ]),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Procesando...')),
                );

                final values = _formKey.currentState!.instantValue;

                final data = {
                  'firstName': values['firstName'] as String,
                  'lastName': values['lastName'] as String,
                  'username': values['username'] as String,
                };

                try {
                  _userService.createProfile(data).then((value) {
                    if (context.mounted) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute<HomeScreen>(
                              builder: (context) => const HomeScreen()));
                    }
                  });
                } on Map<String, String> catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(e['error'] ?? 'Ocurrió un error')));
                  }
                }
              }
            },
            child: const Text('Crear perfil'),
          ),
        ],
      ),
    );
  }
}

class UpdateProfilePictureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: UpdateProfilePictureForm()),
    );
  }
}

class UpdateProfilePictureForm extends StatefulWidget {
  UpdateProfilePictureForm({super.key});

  @override
  State createState() {
    return UpdateProfilePictureFormState();
  }
}

class UpdateProfilePictureFormState extends State<UpdateProfilePictureForm> {
  UserService _userService = UserServiceImpl.instance;
  XFile? _file;
  final ImagePicker _picker = ImagePicker();
  dynamic _pickImageError;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dynamic bgImage = _file != null
        ? FileImage(File(_file!.path))
        : const AssetImage('assets/images/user-placeholder.jpg');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: () async {
              if (!context.mounted) return;

              try {
                final XFile? pickedFiles = await _picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 2000,
                  maxHeight: 2000,
                );

                setState(() {
                  _file = pickedFiles;
                });
              } catch (e) {
                setState(() {
                  _pickImageError = e;
                });
              }
            },
            icon: CircleAvatar(
              radius: 48,
              backgroundImage: bgImage,
            )),
        TextButton(
            onPressed: () async {
              final file = _file;
              if (file == null) return;

              try {
                await _userService.updateProfilePicture(file);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ocurrió un error al intentar actualizar la foto de perfil')));
              }
            },
            child: const Text('Guardar'))
      ],
    );
  }
}
