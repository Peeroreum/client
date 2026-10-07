import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:peeroreum_client/designs/peeroreum_toast.dart';
import 'package:get/get.dart';
import 'package:peeroreum_client/designs/peeroreum_color.dart';
import 'package:peeroreum_client/api/api_client.dart';
import './validate_screen.dart';

class EmailSearch extends StatefulWidget {
  const EmailSearch({super.key});

  @override
  State<EmailSearch> createState() => _EmailSearchState();
}

class _EmailSearchState extends State<EmailSearch> {
  final emailController = TextEditingController();
  bool isEnabled = false;
  bool emailShowClearButton = false;
  bool emailFocus = false;
  bool isLoading = false;

  void _checkInput() {
    if (RegExp(
            r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(emailController.text)) {
      setState(() {
        isEnabled = true;
      });
    } else {
      setState(() {
        isEnabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          emailShowClearButton = false;
          emailFocus = false;
        });
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0.0,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back,
              color: PeeroreumColor.gray[800],
            ),
          ),
        ),
        body: SafeArea(
          child: Container(
            color: PeeroreumColor.white,
            child: SingleChildScrollView(
              reverse: true,
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom * 0.3),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '비밀번호 재설정',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: PeeroreumColor.black),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    const Text(
                      '이메일을 입력해 주세요.',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: PeeroreumColor.black),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: TextFormField(
                          controller: emailController,
                          onTap: () {
                            if (emailController.text.isNotEmpty) {
                              setState(() {
                                emailShowClearButton = true;
                              });
                            }
                            setState(() {
                              emailFocus = true;
                            });
                          },
                          onChanged: (value) {
                            _checkInput();
                            setState(() {
                              if (value.isNotEmpty) {
                                emailShowClearButton = true;
                              } else {
                                emailShowClearButton = false;
                              }
                            });
                          },
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (value) {
                            emailFocus = false;
                          },
                          decoration: InputDecoration(
                            hintText: 'peer@mail.com',
                            hintStyle: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: PeeroreumColor.gray[600]),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: PeeroreumColor.error)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: PeeroreumColor.error,
                                )),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            suffixIcon: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: emailShowClearButton
                                        ? GestureDetector(
                                            onTap: () {
                                              emailController.clear();
                                              setState(() {
                                                emailShowClearButton = false;
                                                _checkInput();
                                              });
                                            },
                                            child: SvgPicture.asset(
                                              "assets/icons/x_circle.svg",
                                              colorFilter: ColorFilter.mode(
                                                  PeeroreumColor.gray[200]!,
                                                  BlendMode.srcIn),
                                            ))
                                        : null),
                                const SizedBox(
                                  width: 12,
                                )
                              ],
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: PeeroreumColor.black,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: PeeroreumColor.gray[200]!,
                              ),
                            ),
                          ),
                          cursorColor: PeeroreumColor.gray[600]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomSheet: SafeArea(
          child: Container(
            color: PeeroreumColor.white,
            padding: MediaQuery.of(context).viewInsets.bottom > 0
                ? EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom)
                : const EdgeInsets.fromLTRB(20, 8, 20, 28),
            width: MediaQuery.of(context).size.width,
            child: SizedBox(
              height: 48,
              child: TextButton(
                onPressed: (isEnabled && !isLoading)
                    ? () async {
                        final exists = await isExistingEmail();
                        if (!mounted) return;
                        if (exists == null) {
                          PeeroreumToast.show(
                              context, // ignore: use_build_context_synchronously
                              "잠시 후에 다시 시도해 주세요.",
                              isError: true);
                          return;
                        }
                        if (!exists) {
                          PeeroreumToast.show(
                              context, // ignore: use_build_context_synchronously
                              "해당 이메일로 가입된 계정이 없어요",
                              isError: true);
                          return;
                        }
                        sendEmail();
                      }
                    : null,
                style: ButtonStyle(
                    backgroundColor: (isEnabled && !isLoading)
                        ? WidgetStateProperty.all(
                            PeeroreumColor.primaryPurple[400])
                        : WidgetStateProperty.all(PeeroreumColor.gray[300]),
                    padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 12)),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: MediaQuery.of(context).viewInsets.bottom > 0
                          ? BorderRadius.zero
                          : BorderRadius.circular(8.0),
                    ))),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: PeeroreumColor.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        '다음',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                            color: PeeroreumColor.white),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> isExistingEmail() async {
    try {
      var result =
          await ApiClient().get('/signup/email/${emailController.text}');
      return result.statusCode == 409;
    } catch (e) {
      return null;
    }
  }

  sendEmail() async {
    setState(() {
      isLoading = true;
    });
    final dynamic result;
    try {
      result = await ApiClient().post(
        '/member/password/email?email=${Uri.encodeComponent(emailController.text)}',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      PeeroreumToast.show(context, "메일을 전송할 수 없어요. 다시 시도해 주세요.", isError: true);
      return;
    }
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
    if (result.statusCode == 200) {
      var data = result.data;
      if (data['status'] == 'success') {
        Get.to(() => EmailValidate(emailController.text),
            transition: Transition.noTransition);
      } else {
        if (!mounted) return;
        PeeroreumToast.show(context, "메일 전송에 실패했어요.", isError: true);
      }
    } else {
      if (!mounted) return;
      PeeroreumToast.show(context, "메일을 전송할 수 없어요. 다시 시도해 주세요.", isError: true);
    }
  }
}
