// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'files_query_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FilesQueryEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilesQueryEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FilesQueryEvent()';
}


}

/// @nodoc
class $FilesQueryEventCopyWith<$Res>  {
$FilesQueryEventCopyWith(FilesQueryEvent _, $Res Function(FilesQueryEvent) __);
}


/// Adds pattern-matching-related methods to [FilesQueryEvent].
extension FilesQueryEventPatterns on FilesQueryEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( FetchFiles value)?  fetch,TResult Function( RefreshFiles value)?  refresh,required TResult orElse(),}){
final _that = this;
switch (_that) {
case FetchFiles() when fetch != null:
return fetch(_that);case RefreshFiles() when refresh != null:
return refresh(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FetchFiles value)  fetch,required TResult Function( RefreshFiles value)  refresh,}){
final _that = this;
switch (_that) {
case FetchFiles():
return fetch(_that);case RefreshFiles():
return refresh(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( FetchFiles value)?  fetch,TResult? Function( RefreshFiles value)?  refresh,}){
final _that = this;
switch (_that) {
case FetchFiles() when fetch != null:
return fetch(_that);case RefreshFiles() when refresh != null:
return refresh(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  fetch,TResult Function()?  refresh,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FetchFiles() when fetch != null:
return fetch();case RefreshFiles() when refresh != null:
return refresh();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  fetch,required TResult Function()  refresh,}) {final _that = this;
switch (_that) {
case FetchFiles():
return fetch();case RefreshFiles():
return refresh();case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  fetch,TResult? Function()?  refresh,}) {final _that = this;
switch (_that) {
case FetchFiles() when fetch != null:
return fetch();case RefreshFiles() when refresh != null:
return refresh();case _:
  return null;

}
}

}

/// @nodoc


class FetchFiles implements FilesQueryEvent {
  const FetchFiles();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FetchFiles);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FilesQueryEvent.fetch()';
}


}




/// @nodoc


class RefreshFiles implements FilesQueryEvent {
  const RefreshFiles();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RefreshFiles);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FilesQueryEvent.refresh()';
}


}




// dart format on
