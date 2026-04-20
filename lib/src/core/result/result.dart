import 'package:dartz/dartz.dart';
import 'package:wcr_pmis_mobile/src/core/result/failure.dart';

typedef Result<T> = Either<Failure, T>;
