import 'package:flutter/material.dart';

class DailyMuhasabahCard extends StatefulWidget {
  const DailyMuhasabahCard({super.key});

  @override
  State<DailyMuhasabahCard> createState() =>
      _DailyMuhasabahCardState();
}

class _DailyMuhasabahCardState
    extends State<DailyMuhasabahCard> {
  // Temporary daily Muhasabah.
  //
  // Later this will come from a proper
  // DailyMuhasabahService + Firebase progress.

  final String question =
      'What did you do today that you would want to change if you could live this day again?';

  final String reflectionHint =
      'Take a quiet moment. Be honest with yourself.';

  bool completed = false;

  // ─────────────────────────────────────────────
  // OPEN MUHASABAH
  // ─────────────────────────────────────────────

  Future<void> _openMuhasabah() async {
    if (completed) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor:
          Colors.black.withValues(alpha: .45),
      builder: (_) {
        return _DailyMuhasabahDialog(
          question: question,
          reflectionHint: reflectionHint,
          onCompleted: () {
            if (!mounted) return;

            setState(() {
              completed = true;
            });
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          completed ? null : _openMuhasabah,
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 250),

        margin:
            const EdgeInsets.symmetric(
          horizontal: 20,
        ),

        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),

        decoration: BoxDecoration(
          color:
              const Color(0xffEDE8E0),

          borderRadius:
              BorderRadius.circular(20),

          border: Border.all(
            color:
                const Color(0xff6E6255)
                    .withValues(alpha: .08),
          ),

          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withValues(
                alpha: .045,
              ),
              blurRadius: 14,
              offset:
                  const Offset(0, 6),
            ),
          ],
        ),

        child: completed
            ? _completedHomeCard()
            : _pendingHomeCard(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // PENDING HOME CARD
  // ─────────────────────────────────────────────

  Widget _pendingHomeCard() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                const Color(0xff6E6255)
                    .withValues(alpha: .10),
            borderRadius:
                BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.nightlight_round,
            color:
                Color(0xff6E6255),
            size: 21,
          ),
        ),

        const SizedBox(width: 12),

        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'DAILY MUHASABAH',
                style: TextStyle(
                  color:
                      Color(0xff6E6255),
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),

              SizedBox(height: 3),

              Text(
                'Take a moment to look within',
                style: TextStyle(
                  color:
                      Colors.black54,
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color:
                const Color(0xff6E6255),
            borderRadius:
                BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white,
            size: 17,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // COMPLETED HOME CARD
  // ─────────────────────────────────────────────

  Widget _completedHomeCard() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                const Color(0xff6E6255)
                    .withValues(alpha: .10),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color:
                Color(0xff6E6255),
            size: 22,
          ),
        ),

        const SizedBox(width: 12),

        const Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'DAILY MUHASABAH',
                style: TextStyle(
                  color:
                      Color(0xff6E6255),
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),

              SizedBox(height: 3),

              Text(
                'Reflection completed today',
                style: TextStyle(
                  color:
                      Colors.black54,
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const Icon(
          Icons.check_circle_rounded,
          color:
              Color(0xff6E6255),
          size: 21,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
// DAILY MUHASABAH DIALOG
// ═══════════════════════════════════════════════

class _DailyMuhasabahDialog
    extends StatelessWidget {
  final String question;
  final String reflectionHint;
  final VoidCallback onCompleted;

  const _DailyMuhasabahDialog({
    required this.question,
    required this.reflectionHint,
    required this.onCompleted,
  });

  void _complete(BuildContext context) {
    onCompleted();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor:
          Colors.transparent,

      insetPadding:
          const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 24,
      ),

      child: Container(
        constraints:
            const BoxConstraints(
          maxWidth: 500,
        ),

        padding:
            const EdgeInsets.fromLTRB(
          20,
          18,
          20,
          20,
        ),

        decoration: BoxDecoration(
          color:
              const Color(0xffFBF8F1),

          borderRadius:
              BorderRadius.circular(26),

          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withValues(
                alpha: .15,
              ),
              blurRadius: 30,
              offset:
                  const Offset(0, 12),
            ),
          ],
        ),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            // ─────────────────────────────
            // HEADER
            // ─────────────────────────────

            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xff6E6255,
                    ).withValues(
                      alpha: .10,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: const Icon(
                    Icons.nightlight_round,
                    color:
                        Color(0xff6E6255),
                    size: 20,
                  ),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    'DAILY MUHASABAH',
                    style: TextStyle(
                      color:
                          Color(0xff6E6255),
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                IconButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    color:
                        Colors.black45,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ─────────────────────────────
            // REFLECTION SYMBOL
            // ─────────────────────────────

            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color:
                    const Color(0xffEDE8E0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.self_improvement_rounded,
                color:
                    Color(0xff6E6255),
                size: 28,
              ),
            ),

            const SizedBox(height: 20),

            // ─────────────────────────────
            // QUESTION
            // ─────────────────────────────

            const Text(
              'TAKE A MOMENT',
              style: TextStyle(
                color:
                    Color(0xff6E6255),
                fontSize: 11,
                fontWeight:
                    FontWeight.w800,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              question,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Color(0xff182C2A),
                fontSize: 21,
                fontWeight:
                    FontWeight.w700,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 14),

            // ─────────────────────────────
            // REFLECTION HINT
            // ─────────────────────────────

            Text(
              reflectionHint,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Colors.black54,
                fontSize: 13,
                fontStyle:
                    FontStyle.italic,
                height: 1.45,
              ),
            ),

            const SizedBox(height: 24),

            // ─────────────────────────────
            // COMPLETE
            // ─────────────────────────────

            SizedBox(
              width: double.infinity,

              child:
                  GestureDetector(
                onTap: () =>
                    _complete(context),

                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 13,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xff6E6255,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),

                  child: const Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      Text(
                        'I’VE REFLECTED',
                        style:
                            TextStyle(
                          color:
                              Colors.white,
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),

                      SizedBox(width: 6),

                      Icon(
                        Icons
                            .check_rounded,
                        color:
                            Colors.white,
                        size: 17,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}