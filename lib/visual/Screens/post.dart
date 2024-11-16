import 'package:UgmaNet/services/post_service.dart';
import 'package:UgmaNet/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CreatePostForm(),
    );
  }
}

class CreatePostForm extends StatefulWidget {
  const CreatePostForm({super.key});

  @override
  State<StatefulWidget> createState() {
    return CreatePostFormState();
  }
}

class CreatePostFormState extends State<CreatePostForm> {
  final _postFormKey = GlobalKey<FormBuilderState>();
  final PostService _postService = PostServiceImpl.instance;
  final UserService _userService = UserServiceImpl.instance;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FormBuilder(
        key: _postFormKey,
        child: Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FormBuilderTextField(
              name: 'content',
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.maxLength(280,
                    errorText:
                        'Máximo número de caracteres alcanzado. Máximo 280.'),
              ]),
            ),

            TextButton(
              onPressed: () async {
                if (_postFormKey.currentState!.validate()) {
                  final values = _postFormKey.currentState!.instantValue;

                  final content = values['content'] as String;

                  final user = await _userService.getCurrentUser();

                  if (user == null) {
                    throw Exception('Usuario no ha iniciado sesion');
                  }

                  try {
                    await _postService.savePost(content, user.uid);
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              'Ocurrió un error al intentar crear el post')));
                    }
                  }
                }
              },
              child: const Text('Crear post'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _displayPickImageDialog(
      BuildContext context, bool isMulti, OnPickImageCallback onPick) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add optional parameters'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                  child: const Text('PICK'),
                  onPressed: () {
                    final double width = 5000;
                    final double height = 5000;
                    final int quality = 100;
                    final int? limit = 1;
                    onPick(width, height, quality, limit);
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }

}

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality, int? limit);
