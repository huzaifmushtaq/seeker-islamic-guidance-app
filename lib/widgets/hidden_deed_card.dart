import 'package:flutter/material.dart';

class HiddenDeedCard extends StatefulWidget {
  const HiddenDeedCard({super.key});

  @override
  State<HiddenDeedCard> createState() =>
      _HiddenDeedCardState();
}

class _HiddenDeedCardState
    extends State<HiddenDeedCard> {
  // ─────────────────────────────────────────────
  // HIDDEN DEEDS
  //
  // Temporary local library.
  // Later these can come from Firestore /
  // a dedicated HiddenDeedService.
  // ─────────────────────────────────────────────

  final List<String> deeds = [
    'Make sincere dua for someone without ever telling them.',

    'Help someone today without letting them know you were behind it.',

    'Forgive someone silently without announcing that you forgave them.',

    'Give something in charity anonymously.',

    'Make someone’s difficult task easier without seeking recognition.',

    'Do something kind for your family when nobody is watching.',

    'Make dua for someone you find difficult to forgive.',

    'Pray two extra rak‘ahs privately, without telling anyone.',

    'Conceal someone’s mistake instead of exposing it.',

    'Give someone sincere praise without expecting anything in return.',
  ];

  bool completed = false;

  // ─────────────────────────────────────────────
  // TODAY'S DEED
  // ─────────────────────────────────────────────

  String get todayDeed {
    final now = DateTime.now();

    final startOfYear =
        DateTime(now.year, 1, 1);

    final dayOfYear =
        now.difference(startOfYear).inDays;

    return deeds[dayOfYear % deeds.length];
  }

  // ─────────────────────────────────────────────
  // OPEN
  // ─────────────────────────────────────────────

  Future<void> _openHiddenDeed() async {
    if (completed) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor:
          Colors.black.withValues(alpha: .45),
      builder: (_) {
        return _HiddenDeedDialog(
          deed: todayDeed,
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
  // BUILD HOME CARD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          completed ? null : _openHiddenDeed,

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
              const Color(0xffF1EEE7),

          borderRadius:
              BorderRadius.circular(20),

          border: Border.all(
            color:
                const Color(0xff536B63)
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
            ? _completedView()
            : _pendingView(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // PENDING HOME CARD
  // ─────────────────────────────────────────────

  Widget _pendingView() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,

          decoration: BoxDecoration(
            color:
                const Color(0xff536B63)
                    .withValues(alpha: .10),

            borderRadius:
                BorderRadius.circular(13),
          ),

          child: const Icon(
            Icons.visibility_off_rounded,
            color:
                Color(0xff536B63),
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
                'HIDDEN DEED',
                style: TextStyle(
                  color:
                      Color(0xff536B63),
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),

              SizedBox(height: 3),

              Text(
                'Do something good unseen',
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
                const Color(0xff536B63),

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

  Widget _completedView() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,

          decoration: BoxDecoration(
            color:
                const Color(0xff536B63)
                    .withValues(alpha: .10),

            shape: BoxShape.circle,
          ),

          child: const Icon(
            Icons.check_rounded,
            color:
                Color(0xff536B63),
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
                'HIDDEN DEED',
                style: TextStyle(
                  color:
                      Color(0xff536B63),
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),

              SizedBox(height: 3),

              Text(
                'Kept between you and Allah',
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
              Color(0xff536B63),
          size: 21,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
// HIDDEN DEED DIALOG
// ═══════════════════════════════════════════════

class _HiddenDeedDialog
    extends StatelessWidget {
  final String deed;
  final VoidCallback onCompleted;

  const _HiddenDeedDialog({
    required this.deed,
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
                      0xff536B63,
                    ).withValues(
                      alpha: .10,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),

                  child: const Icon(
                    Icons
                        .visibility_off_rounded,
                    color:
                        Color(0xff536B63),
                    size: 20,
                  ),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    'HIDDEN DEED',
                    style: TextStyle(
                      color:
                          Color(0xff536B63),
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

                  icon:
                      const Icon(
                    Icons.close_rounded,
                    color:
                        Colors.black45,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ─────────────────────────────
            // SYMBOL
            // ─────────────────────────────

            Container(
              width: 60,
              height: 60,

              decoration:
                  const BoxDecoration(
                color:
                    Color(0xffE8E5DD),
                shape:
                    BoxShape.circle,
              ),

              child: const Icon(
                Icons
                    .volunteer_activism_rounded,
                color:
                    Color(0xff536B63),
                size: 29,
              ),
            ),

            const SizedBox(height: 20),

            // ─────────────────────────────
            // TITLE
            // ─────────────────────────────

            const Text(
              "TODAY'S HIDDEN DEED",
              style: TextStyle(
                color:
                    Color(0xff536B63),
                fontSize: 11,
                fontWeight:
                    FontWeight.w800,
                letterSpacing: .9,
              ),
            ),

            const SizedBox(height: 12),

            // ─────────────────────────────
            // DEED
            // ─────────────────────────────

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
                    const Color(0xffF1EEE7),

                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),

              child: Text(
                deed,
                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  color:
                      Color(0xff182C2A),
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ─────────────────────────────
            // PHILOSOPHY
            // ─────────────────────────────

            const Text(
              'No one needs to know.',
              textAlign:
                  TextAlign.center,

              style: TextStyle(
                color:
                    Colors.black54,
                fontSize: 13,
                fontStyle:
                    FontStyle.italic,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Keep this between you and Allah.',
              textAlign:
                  TextAlign.center,

              style: TextStyle(
                color:
                    Colors.black45,
                fontSize: 11,
                fontWeight:
                    FontWeight.w500,
              ),
            ),

            const SizedBox(height: 24),

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
                      0xff536B63,
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
                        Icons.check_rounded,
                        color:
                            Colors.white,
                        size: 17,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'May Allah accept it.',
              style: TextStyle(
                color:
                    Colors.black45,
                fontSize: 10,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}