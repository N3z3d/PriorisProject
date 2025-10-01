/// **GET TASK STATISTICS QUERY** - CQRS Pattern
import '../../services/application_service.dart';
import '../../../domain/core/value_objects/export.dart';

class GetTaskStatisticsQuery extends Query {
  final DateRange? dateRange;

  GetTaskStatisticsQuery({this.dateRange});
}