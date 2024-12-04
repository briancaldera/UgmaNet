import 'dart:io';
import 'package:UgmaNet/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';

class CreateProfileScreen extends StatelessWidget {
  const CreateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      padding: const EdgeInsets.only(left: 30, right: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/logo/UGMA-LOGO.png', height: 150, width: 150,),
          const Padding(
            padding: EdgeInsets.only(top: 20, bottom: 20),
            child: Text('Procedamos a crear tu perfil de usuario'),
          ),
          const CreateProfileForm()
        ],
      ),
    ),
  );
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

  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FormBuilderTextField(
            maxLength: 20,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.alternate_email_rounded),
              labelText: 'Nombre de usuario',
              border: OutlineInputBorder(),
              helperText:
                  'Ejemplo: @johnd123',
            ),
            name: 'username',
            onChanged: (val) {},
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                  errorText: 'El campo es requerido'),
              FormBuilderValidators.username(
                  maxLength: 20,
                  minLength: 3,
                  allowUnderscore: true,
                  allowSpace: false,
                  allowNumbers: true,
                  allowDash: false,
                  allowSpecialChar: true,
                  allowDots: true,
                  errorText: 'No debe contener espacios en blanco o símbolos otros que . y _')
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
              FormBuilderValidators.firstName(errorText: 'Inválido. Debe comenzar por mayúscula, sin espacios.')
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
              FormBuilderValidators.lastName(errorText: 'Inválido. Debe comenzar por mayúscula, sin espacios.')
            ]),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: _isProcessing ? null : _submitFormHandler,
            child: const Text('Crear perfil'),
          ),
        ],
      ),
    );
  }

  void _submitFormHandler() async {

    final context = this.context;

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
        setState(() {
          _isProcessing = true;
        });

        await _userService.createProfile(data);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil creado')),
          );
        }

      } on Map<String, String> catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(e['error'] ?? 'Ocurrió un error')));
        }
      } finally {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}

class UpdateProfilePictureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: UpdateProfilePictureForm()),
    );
  }

  const UpdateProfilePictureScreen({super.key});
}

class UpdateProfilePictureForm extends StatefulWidget {
  const UpdateProfilePictureForm({super.key});

  @override
  State createState() {
    return UpdateProfilePictureFormState();
  }
}

class UpdateProfilePictureFormState extends State<UpdateProfilePictureForm> {
  final UserService _userService = UserServiceImpl.instance;
  XFile? _file;
  final ImagePicker _picker = ImagePicker();

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
                // todo catch error
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
