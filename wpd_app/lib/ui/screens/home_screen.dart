import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:wpd_app/models/user/user.dart';

import 'package:wpd_app/ui/widgets/case_tile.dart';
import 'package:wpd_app/ui/widgets/category_tile.dart';
import 'package:wpd_app/ui/widgets/loader.dart';
import 'package:wpd_app/view_models/auth_state_viewmodel.dart';
import 'package:wpd_app/view_models/home_screen_viewmodel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    ref.read(HomeScreenViewModelProvider.provider).getCategories();
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(AuthStateViewModelProvider.provider).myUser?.role;
    return RefreshIndicator(
      color: Theme.of(context).primaryColor,
      onRefresh: () => ref
          .read(HomeScreenViewModelProvider.provider)
          .getCategories(refresh: true),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          leading: IconButton(
            onPressed: () {},
            iconSize: 32,
            tooltip: 'History',
            color: Theme.of(context).primaryColor,
            icon: const Icon(Icons.history),
          ),
          actions: [
            if (role == Roles.admin || role == Roles.regular)
              IconButton(
                icon: const Icon(Icons.add),
                iconSize: 32,
                tooltip: 'Add Case',
                onPressed: () {
                  Routemaster.of(context).push('add');
                },
              )
          ],
        ),
        body: Consumer(
          builder: (context, ref, child) {
            final homeViewModel =
                ref.watch(HomeScreenViewModelProvider.provider);

            return homeViewModel.isLoading
                ? ListView.builder(
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      return const ShimmerLoader();
                    },
                  )
                : homeViewModel.categories.isEmpty
                    ? Center(
                        child: Text(
                          'Empty...',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      )
                    : ListView.builder(
                        itemCount: homeViewModel.categories.length,
                        itemBuilder: (context, index) {
                          final category = homeViewModel.categories[index];

                          return CategoryTile(category: category);
                        },
                      );
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(
            Icons.search,
            size: 30,
          ),
          onPressed: () {
            Routemaster.of(context).push('search');
          },
        ),
      ),
    );
  }
}

class SingleCategoryScreen extends HookConsumerWidget {
  const SingleCategoryScreen({
    Key? key,
    required this.categoryId,
  }) : super(key: key);

  final String? categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeViewModel = ref.watch(HomeScreenViewModelProvider.provider);

    // initState
    useEffect(() {
      homeViewModel.getCases(categoryId: categoryId!);
    }, []);

    return RefreshIndicator(
      color: Theme.of(context).primaryColor,
      onRefresh: () => ref
          .read(HomeScreenViewModelProvider.provider)
          .getCases(refresh: true, categoryId: categoryId!),
      child: Scaffold(
        appBar: AppBar(
          title: Text(homeViewModel.selectedCateogry!.title),
        ),
        body: homeViewModel.isLoading
            ? ListView.builder(
                itemCount: 7,
                itemBuilder: (context, index) {
                  return const ShimmerLoader();
                },
              )
            : homeViewModel.myCases.isEmpty
                ? Center(
                    child: Text(
                      'Empty...',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  )
                : ListView.separated(
                    itemCount: homeViewModel.myCases.length,
                    itemBuilder: (context, index) {
                      final myCase = homeViewModel.myCases[index];

                      return CaseTile(myCase: myCase);
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 3),
                  ),
      ),
    );
  }
}
