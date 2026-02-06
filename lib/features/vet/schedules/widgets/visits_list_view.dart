import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/widgets/vet_unverified_banner.dart';
import 'package:agriflock360/features/vet/schedules/models/visit_model.dart';
import 'package:agriflock360/features/vet/schedules/repo/visit_repo.dart';
import 'package:agriflock360/features/vet/schedules/widgets/visit_card.dart';
import 'package:flutter/material.dart';

class VisitsListView extends StatefulWidget {
  final String status;
  final VisitsRepository repository;
  final VoidCallback onVisitUpdated;

  const VisitsListView({
    super.key,
    required this.status,
    required this.repository,
    required this.onVisitUpdated,
  });

  @override
  State<VisitsListView> createState() => _VisitsListViewState();
}

class _VisitsListViewState extends State<VisitsListView>
    with AutomaticKeepAliveClientMixin {
  final List<Visit> _visits = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  String? _errorCond;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final result = await widget.repository.getVetVisitsByStatus(
      status: widget.status,
    );

    LogUtil.warning(widget.status);

    if (mounted) {
      if (result case Failure(:final cond, :final message)) {
        setState(() {
          _hasError = true;
          _errorCond = cond;
          _errorMessage = message;
          _isLoading = false;
        });
        return;
      }

      result.when(
        success: (visits) {
          setState(() {
            _visits.clear();
            _visits.addAll(visits);
            _hasError = false;
            _errorCond = null;
            _errorMessage = '';
            _isLoading = false;
          });
        },
        failure: (_, __, ___) {},
      );
    }
  }

  void _onVisitActionCompleted() {
    _loadVisits();
    widget.onVisitUpdated();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_hasError && _visits.isEmpty) {
      if (_errorCond == 'unverified_vet') {
        return VetUnverifiedBanner(onRefresh: _loadVisits);
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _errorMessage,
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadVisits,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_isLoading && _visits.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_visits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No visits found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVisits,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _visits.length,
        itemBuilder: (context, index) {
          return VisitCard(
            visit: _visits[index],
            repository: widget.repository,
            onActionCompleted: _onVisitActionCompleted,
          );
        },
      ),
    );
  }
}