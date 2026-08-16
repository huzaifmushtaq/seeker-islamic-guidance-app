import 'package:flutter/material.dart';

class DailyAmalCard extends StatefulWidget {
  const DailyAmalCard({super.key});

  @override
  State<DailyAmalCard> createState() =>
      _DailyAmalCardState();
}

class _DailyAmalCardState
    extends State<DailyAmalCard> {
  // Temporary daily Amal.
  //
  // We will later replace this with the proper
  // DailyAmalService + Firebase-backed progress.
  final String amalTitle =
      'Speak gently to someone today';

  final String amalDescription =
      'Especially when you have a reason to be angry.';

  final String source =
      '“And speak to people good words.”';

  final String reference =
      'Qur’an 2:83';

  bool completed = false;

  // ─────────────────────────────────────────────
  // OPEN AMAL
  // ─────────────────────────────────────────────

  Future<void> _openAmal() async {
    if (completed) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor:
          Colors.black.withValues(alpha: .45),
      builder: (_) {
        return _DailyAmalDialog(
          title: amalTitle,
          description: amalDescription,
          source: source,
          reference: reference,
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
          completed ? null : _openAmal,
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
              const Color(0xffF4EBDD),

          borderRadius:
              BorderRadius.circular(20),

          border: Border.all(
            color:
                const Color(0xff8B6F3D)
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
  // PENDING
  // ─────────────────────────────────────────────

  Widget _pendingHomeCard() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                const Color(0xff8B6F3D)
                    .withValues(alpha: .10),
            borderRadius:
                BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.spa_rounded,
            color:
                Color(0xff8B6F3D),
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
                'DAILY AMAL',
                style: TextStyle(
                  color:
                      Color(0xff8B6F3D),
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),

              SizedBox(height: 3),

              Text(
                'Practice today’s teaching',
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
                const Color(0xff8B6F3D),
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
  // COMPLETED
  // ─────────────────────────────────────────────

  Widget _completedHomeCard() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                const Color(0xff8B6F3D)
                    .withValues(alpha: .10),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color:
                Color(0xff8B6F3D),
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
                'DAILY AMAL',
                style: TextStyle(
                  color:
                      Color(0xff8B6F3D),
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),

              SizedBox(height: 3),

              Text(
                'Completed today',
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
              Color(0xff8B6F3D),
          size: 21,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
// DAILY AMAL DIALOG
// ═══════════════════════════════════════════════

class _DailyAmalDialog extends StatelessWidget {
  final String title;
  final String description;
  final String source;
  final String reference;
  final VoidCallback onCompleted;

  const _DailyAmalDialog({
    required this.title,
    required this.description,
    required this.source,
    required this.reference,
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
                      0xff8B6F3D,
                    ).withValues(
                      alpha: .10,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: const Icon(
                    Icons.spa_rounded,
                    color:
                        Color(0xff8B6F3D),
                    size: 20,
                  ),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    'DAILY AMAL',
                    style: TextStyle(
                      color:
                          Color(0xff8B6F3D),
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

            const SizedBox(height: 20),

            // ─────────────────────────────
            // TODAY'S ACTION
            // ─────────────────────────────

            const Align(
              alignment:
                  Alignment.centerLeft,
              child: Text(
                'TODAY’S ACTION',
                style: TextStyle(
                  color:
                      Color(0xff8B6F3D),
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 22,
              ),

              decoration:
                  BoxDecoration(
                color:
                    const Color(0xffF4EBDD),

                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),

              child: Column(
                children: [
                  Text(
                    title,
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      color:
                          Color(0xff182C2A),
                      fontSize: 21,
                      fontWeight:
                          FontWeight.w700,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    description,
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      color:
                          Colors.black54,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ─────────────────────────────
            // SOURCE
            // ─────────────────────────────

            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),

              decoration:
                  BoxDecoration(
                color:
                    Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),

              child: Column(
                children: [
                  Text(
                    source,
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      color:
                          Color(0xff182C2A),
                      fontSize: 14,
                      fontStyle:
                          FontStyle.italic,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    reference,
                    style:
                        const TextStyle(
                      color:
                          Color(0xff8B6F3D),
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ─────────────────────────────
            // COMPLETE
            // ─────────────────────────────

            SizedBox(
              width: double.infinity,

              child: GestureDetector(
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
                      0xff8B6F3D,
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
                        'I DID IT',
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