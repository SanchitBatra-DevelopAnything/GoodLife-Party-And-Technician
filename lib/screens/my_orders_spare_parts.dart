import 'package:flutter/material.dart';
import 'package:goodlife_party/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../screens/executive_order_details_screen.dart';
import '../widgets/executive_order_card.dart';

class SparePartsOrdersScreen extends StatefulWidget {
  const SparePartsOrdersScreen({super.key});

  @override
  State<SparePartsOrdersScreen> createState() =>
      SparePartsOrdersScreenState();
}

class SparePartsOrdersScreenState
    extends State<SparePartsOrdersScreen> {
  bool showExecutiveOrders = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    final authProvider =
        context.read<AuthProvider>();

    await context
        .read<OrderProvider>()
        .fetchExecutiveDeliveryOrders(
          authProvider.distributorName,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(90),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary,
            borderRadius:
                const BorderRadius.vertical(
                  bottom:
                      Radius.circular(26),
                ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                )
                    .colorScheme
                    .primary
                    .withOpacity(0.18),
                blurRadius: 14,
                offset: const Offset(
                  0,
                  6,
                ),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.all(
                          12,
                        ),
                    decoration:
                        BoxDecoration(
                          color: Colors.white
                              .withOpacity(
                                0.15,
                              ),
                          borderRadius:
                              BorderRadius.circular(
                                16,
                              ),
                        ),
                    child: const Icon(
                      Icons
                          .local_shipping_rounded,
                      color:
                          Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        const Text(
                          'Spare Parts Orders',
                          style: TextStyle(
                            color:
                                Colors.white,
                            fontSize: 22,
                            fontWeight:
                                FontWeight
                                    .bold,
                            letterSpacing:
                                0.4,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Track your spare parts deliveries',
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              TextStyle(
                                color: Colors
                                    .white
                                    .withOpacity(
                                      0.85,
                                    ),
                                fontSize:
                                    14,
                                fontWeight:
                                    FontWeight
                                        .w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.all(
                          10,
                        ),
                    decoration:
                        BoxDecoration(
                          color: Colors.white
                              .withOpacity(
                                0.12,
                              ),
                          borderRadius:
                              BorderRadius.circular(
                                14,
                              ),
                        ),
                    child: const Icon(
                      Icons
                          .inventory_2_outlined,
                      color:
                          Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.all(
                  16,
                ),
            child: SegmentedButton<
                bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: true,
                  label: Text(
                    'Executive Delivery',
                  ),
                  icon: Icon(
                    Icons
                        .local_shipping,
                  ),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text(
                    'Custom Orders',
                  ),
                  icon: Icon(
                    Icons.build,
                  ),
                ),
              ],
              selected: {
                showExecutiveOrders,
              },
              onSelectionChanged: (
                value,
              ) {
                setState(() {
                  showExecutiveOrders =
                      value.first;
                });
              },
            ),
          ),

          Expanded(
            child:
                showExecutiveOrders
                    ? _buildExecutiveOrders()
                    : _buildCustomOrders(),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
          currentIndex: 4,
          showCartBar: false,
        ),
    );
  }

  Widget _buildCustomOrders() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
              horizontal: 32,
            ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.build_circle_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(
              height: 16,
            ),
            const Text(
              'Custom Orders Coming Soon',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutiveOrders() {
    return Consumer<OrderProvider>(
      builder: (
        context,
        provider,
        child,
      ) {
        if (provider
            .executiveOrdersLoading) {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        if (provider
                .executiveOrdersError !=
            null) {
          return Center(
            child: Padding(
              padding:
                  const EdgeInsets.all(
                    24,
                  ),
              child: Text(
                provider
                    .executiveOrdersError!,
                textAlign:
                    TextAlign.center,
              ),
            ),
          );
        }

        if (provider
            .executiveOrders.isEmpty) {
          return RefreshIndicator(
            onRefresh: _loadOrders,
            child: ListView(
              children: [
                SizedBox(
                  height:
                      MediaQuery.of(
                            context,
                          ).size.height *
                          0.25,
                ),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons
                            .inventory_2_outlined,
                        size: 90,
                        color: Colors
                            .grey
                            .shade400,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      const Text(
                        'No Executive Delivery Orders Found',
                        style: TextStyle(
                          fontSize:
                              18,
                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Your executive delivery orders will appear here.',
                        textAlign:
                            TextAlign
                                .center,
                        style:
                            TextStyle(
                              color: Colors
                                  .grey
                                  .shade600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadOrders,
          child: ListView.builder(
            padding:
                const EdgeInsets.only(
                  bottom: 24,
                ),
            itemCount:
                provider
                    .executiveOrders
                    .length,
            itemBuilder: (
              context,
              index,
            ) {
              final order =
                  provider
                      .executiveOrders[index];

              return ExecutiveOrderCard(
                order: order,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              ExecutiveOrderDetailsScreen(
                                order:
                                    order,
                              ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}