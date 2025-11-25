import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/focus_timer_provider.dart';
import '../utils/constants.dart';
import '../widgets/theme_toggle_button.dart';

class FocusModeScreen extends StatelessWidget {
  const FocusModeScreen({super.key});

  void _showEditTextDialog(
    BuildContext context,
    FocusTimerProvider timerProvider,
  ) {
    final textController = TextEditingController(text: timerProvider.focusText);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Motivation"),
        content: TextField(
          controller: textController,
          maxLength: 100,
          decoration: const InputDecoration(
            hintText: "Enter your motivational quote",
          ),
          maxLines: 3,
          minLines: 1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              timerProvider.updateFocusText(textController.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, Color(0xFF8F85FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > constraints.maxHeight;
              final timerSize = isLandscape
                  ? constraints.maxHeight * 0.4
                  : 300.0;
              final fontSize = isLandscape ? 45.0 : 80.0;
              final verticalSpacing = isLandscape ? 10.0 : 60.0;
              final buttonPadding = isLandscape ? 14.0 : 20.0;
              final playButtonPadding = isLandscape ? 18.0 : 24.0;
              final buttonIconSize = isLandscape ? 22.0 : 32.0;
              final playIconSize = isLandscape ? 34.0 : 48.0;

              return Stack(
                children: [
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: ThemeToggleButton(
                      color: Colors.white,
                    ),
                  ),
                  // Main Content - Scrollable
                  Padding(
                    padding: EdgeInsets.only(
                      top: 60,
                      bottom: isLandscape ? 40 : 0,
                    ),
                    child: SingleChildScrollView(
                      child: SizedBox(
                        height:
                            constraints.maxHeight - (isLandscape ? 100 : 60),
                        child: Consumer<FocusTimerProvider>(
                          builder: (context, timerProvider, child) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: isLandscape ? 5.0 : 40.0,
                                horizontal: 20.0,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Timer Display with Progress
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: timerSize,
                                        height: timerSize,
                                        child: CircularProgressIndicator(
                                          value: 1.0 - timerProvider.progress,
                                          strokeWidth: isLandscape ? 6 : 8,
                                          backgroundColor: Colors.white
                                              .withOpacity(0.1),
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                Color
                                              >(Colors.white),
                                          strokeCap: StrokeCap.round,
                                        ),
                                      ),
                                      Text(
                                        timerProvider.displayTime,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: fontSize,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: verticalSpacing),

                                  // Controls
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Reset Button
                                      GestureDetector(
                                        onTap: () {
                                          if (timerProvider.elapsedSeconds >=
                                                  120 &&
                                              timerProvider.isRunning) {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                  "Stop Timer?",
                                                ),
                                                content: const Text(
                                                  "You've been focused for a while. Are you sure you want to stop?",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text("Cancel"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      timerProvider
                                                          .resetTimer();
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text(
                                                      "Stop",
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else {
                                            timerProvider.resetTimer();
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(
                                            buttonPadding,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.2,
                                                ),
                                                blurRadius: 10,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.refresh,
                                            color: Colors.white,
                                            size: buttonIconSize,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: isLandscape ? 24 : 32),

                                      // Play/Pause Button
                                      GestureDetector(
                                        onTap: () {
                                          if (timerProvider.isRunning) {
                                            timerProvider.pauseTimer();
                                          } else {
                                            timerProvider.startTimer();
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(
                                            playButtonPadding,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.3,
                                                ),
                                                blurRadius: 15,
                                                offset: const Offset(0, 8),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            timerProvider.isRunning
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            color: AppColors.primary,
                                            size: playIconSize,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (!isLandscape)
                                    SizedBox(height: verticalSpacing),

                                  // Motivational Text (inline for portrait)
                                  if (!isLandscape)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                      ),
                                      child: GestureDetector(
                                        onTap: () => _showEditTextDialog(
                                          context,
                                          timerProvider,
                                        ),
                                        child: Text(
                                          timerProvider.focusText,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Motivational Text (positioned for landscape)
                  if (isLandscape)
                    Positioned(
                      bottom: 6,
                      left: 0,
                      right: 0,
                      child: Consumer<FocusTimerProvider>(
                        builder: (context, timerProvider, child) {
                          return GestureDetector(
                            onTap: () =>
                                _showEditTextDialog(context, timerProvider),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                timerProvider.focusText,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // Back Button
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Always On Toggle
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Consumer<FocusTimerProvider>(
                      builder: (context, timerProvider, child) {
                        return Material(
                          color: Colors.transparent,
                          child: IconButton(
                            onPressed: () {
                              timerProvider.toggleScreenOn();
                              if (timerProvider.isScreenOn) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "The screen will be always on",
                                    ),
                                    duration: Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Screen always on disabled"),
                                    duration: Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            tooltip: "Keep Screen On",
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: timerProvider.isScreenOn
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                timerProvider.isScreenOn
                                    ? Icons.wb_sunny
                                    : Icons.wb_sunny_outlined,
                                color: timerProvider.isScreenOn
                                    ? AppColors.primary
                                    : Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
