import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:validators/validators.dart';
import 'package:wpd_app/models/case/case.dart';
import 'package:wpd_app/ui/widgets/custom_input_text_field.dart';
import 'package:wpd_app/view_models/add_case_screen_viewmodel.dart';
import 'package:wpd_app/view_models/home_screen_viewmodel.dart';

class AddCaseScreen extends HookWidget {
  AddCaseScreen({
    this.caseId,
    this.myCase,
    Key? key,
  }) : super(key: key);

  final String? caseId;
  final Case? myCase;
  final _key = GlobalKey<FormState>();

  String? _validateTitle(String? value) {
    if (value!.isEmpty) {
      return 'Please, write case title';
    } else if (value.trim().isEmpty) {
      return 'Please, write case title';
    } else {
      return null;
    }
  }

  String? _validateDescription(String? value) {
    if (value!.isEmpty) {
      return 'Please, write case description';
    } else if (value.trim().isEmpty) {
      return 'Please, write case description';
    } else {
      return null;
    }
  }

  String? _validateUrl(String? value) {
    if (value!.isEmpty) {
      return 'Please, write case URL';
    } else if (value.trim().isEmpty) {
      return 'Please, write case URL';
    } else if (!isURL(value)) {
      return 'Please, write valid URL';
    } else {
      return null;
    }
  }

  Future<void> _submit(BuildContext context, Case newCase) async {
    if (_key.currentState?.validate() ?? false) {
      await context
          .read(AddCaseScreenViewModelProvider.provider)
          .submitCase(newCase);

      Routemaster.of(context).pop();
      context
          .read(HomeScreenViewModelProvider.provider)
          .getCases(refresh: true);
    } else {
      debugPrint('Error :(');
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final urlController = useTextEditingController();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Form(
        key: _key,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Add Case'),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.add_box_outlined,
                  size: 30,
                ),
                onPressed: () async {
                  await _submit(
                    context,
                    Case(
                      id: 'n/a',
                      title: titleController.text,
                      description: descriptionController.text,
                      url: urlController.text,
                      urlPDF: 'asdas',
                      caseNumber: 0,
                    ),
                  );
                },
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  CustomInputTextField(
                    controller: titleController,
                    initialValue: myCase?.title,
                    validator: _validateTitle,
                    hintText: 'Title',
                    icon: Icons.title,
                  ),
                  CustomInputTextField(
                    controller: descriptionController,
                    initialValue: myCase?.description,
                    validator: _validateDescription,
                    hintText: 'Description',
                    icon: Icons.description,
                    maxLines: 5,
                  ),
                  CustomInputTextField(
                    controller: urlController,
                    initialValue: myCase?.url,
                    validator: _validateUrl,
                    hintText: 'URL',
                    icon: Icons.link,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Upload PDF'),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
