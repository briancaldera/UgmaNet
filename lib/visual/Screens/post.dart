import 'dart:io';
import 'package:UgmaNet/services/post_service.dart';
import 'package:UgmaNet/services/user_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: const CreatePostForm(),
      ),
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
  List<XFile> _mediaFileList = [];

  final _postFormKey = GlobalKey<FormBuilderState>();
  final PostService _postService = PostServiceImpl.instance;
  final UserService _userService = UserServiceImpl.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: FormBuilder(
              key: _postFormKey,
              child: Flex(
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FormBuilderTextField(
                    maxLines: 4,
                    maxLength: 280,
                    decoration: const InputDecoration(
                      hintText: 'Escribe algo cool...',
                      border: OutlineInputBorder(),
                    ),
                    name: 'content',
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.maxLength(280,
                          errorText: 'Máximo número de caracteres alcanzado.'),
                    ]),
                  ),
                  Row(
                    textBaseline: TextBaseline.alphabetic,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      IconButton(
                          onPressed: () async {
                            _onImageButtonPressed(ImageSource.gallery,
                                context: context);
                          },
                          icon: const Icon(Icons.image_rounded)),
                      TextButton(
                        onPressed: () async {
                          if (_postFormKey.currentState!.validate()) {
                            final values = _postFormKey.currentState!.instantValue;
          
                            final content = values['content'] as String;
          
                            final user = _userService.user;
          
                            if (user == null) {
                              throw Exception('Usuario no ha iniciado sesion');
                            }
          
                            try {
                              await _postService.savePost(content, user.uid, images: _mediaFileList.isNotEmpty ? _mediaFileList : null);
                              if (context.mounted) Navigator.pop(context);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
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
                ],
              ),
            ),
          ),
        ),
        Expanded(child: ImagesPreview(_mediaFileList))
      ],
    );
  }

  Future<void> _onImageButtonPressed(ImageSource source, {
    required BuildContext context,
  }) async {
    if (!context.mounted) return;

    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        limit: 4,
        maxHeight: 5000,
        maxWidth: 5000,
      );
        setState(() {
          _mediaFileList = pickedFiles.take(4).toList(growable: false);
        });
    } catch (e) {
      // todo handle error
    }
  }
}

class ImagesPreview extends StatelessWidget {
  final List<XFile> _imagesList;

  const ImagesPreview(this._imagesList, {super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: _imagesList.map((file) => _previewImage(file)).toList(growable: false),
    );
  }

  Widget _previewImage(XFile file) {
    return Semantics(
      label: 'image_picked',
      child: Container(
        decoration: const BoxDecoration(color: Colors.black),
        child: kIsWeb ?
        Image.network(file.path) : Image.file(
          File(file.path), errorBuilder: (BuildContext context, Object error,
            StackTrace? stackTrace) {
          return const Center(
              child:
              Text('This image type is not supported'));
        },),
      ),
    );
  }
}

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality, int? limit);
