// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image2pdf_mutation_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Image2PdfMutationEvent {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Image2PdfMutationEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'Image2PdfMutationEvent()';
}


}

/// @nodoc
class $Image2PdfMutationEventCopyWith<$Res>  {
$Image2PdfMutationEventCopyWith(Image2PdfMutationEvent _, $Res Function(Image2PdfMutationEvent) __);
}


/// Adds pattern-matching-related methods to [Image2PdfMutationEvent].
extension Image2PdfMutationEventPatterns on Image2PdfMutationEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SubmitImage2Pdf value)?  submit,TResult Function( ImagePickRequested value)?  pickRequested,TResult Function( ImagePicked value)?  picked,TResult Function( ImageRemoveAt value)?  removeAt,TResult Function( ImageReordered value)?  reordered,TResult Function( ImageClearSelection value)?  clearSelection,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SubmitImage2Pdf() when submit != null:
return submit(_that);case ImagePickRequested() when pickRequested != null:
return pickRequested(_that);case ImagePicked() when picked != null:
return picked(_that);case ImageRemoveAt() when removeAt != null:
return removeAt(_that);case ImageReordered() when reordered != null:
return reordered(_that);case ImageClearSelection() when clearSelection != null:
return clearSelection(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SubmitImage2Pdf value)  submit,required TResult Function( ImagePickRequested value)  pickRequested,required TResult Function( ImagePicked value)  picked,required TResult Function( ImageRemoveAt value)  removeAt,required TResult Function( ImageReordered value)  reordered,required TResult Function( ImageClearSelection value)  clearSelection,}){
final _that = this;
switch (_that) {
case SubmitImage2Pdf():
return submit(_that);case ImagePickRequested():
return pickRequested(_that);case ImagePicked():
return picked(_that);case ImageRemoveAt():
return removeAt(_that);case ImageReordered():
return reordered(_that);case ImageClearSelection():
return clearSelection(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SubmitImage2Pdf value)?  submit,TResult? Function( ImagePickRequested value)?  pickRequested,TResult? Function( ImagePicked value)?  picked,TResult? Function( ImageRemoveAt value)?  removeAt,TResult? Function( ImageReordered value)?  reordered,TResult? Function( ImageClearSelection value)?  clearSelection,}){
final _that = this;
switch (_that) {
case SubmitImage2Pdf() when submit != null:
return submit(_that);case ImagePickRequested() when pickRequested != null:
return pickRequested(_that);case ImagePicked() when picked != null:
return picked(_that);case ImageRemoveAt() when removeAt != null:
return removeAt(_that);case ImageReordered() when reordered != null:
return reordered(_that);case ImageClearSelection() when clearSelection != null:
return clearSelection(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<String> imagePaths,  String? outputName)?  submit,TResult Function()?  pickRequested,TResult Function( List<String> paths)?  picked,TResult Function( int index)?  removeAt,TResult Function( int fromIndex,  int toIndex)?  reordered,TResult Function()?  clearSelection,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SubmitImage2Pdf() when submit != null:
return submit(_that.imagePaths,_that.outputName);case ImagePickRequested() when pickRequested != null:
return pickRequested();case ImagePicked() when picked != null:
return picked(_that.paths);case ImageRemoveAt() when removeAt != null:
return removeAt(_that.index);case ImageReordered() when reordered != null:
return reordered(_that.fromIndex,_that.toIndex);case ImageClearSelection() when clearSelection != null:
return clearSelection();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<String> imagePaths,  String? outputName)  submit,required TResult Function()  pickRequested,required TResult Function( List<String> paths)  picked,required TResult Function( int index)  removeAt,required TResult Function( int fromIndex,  int toIndex)  reordered,required TResult Function()  clearSelection,}) {final _that = this;
switch (_that) {
case SubmitImage2Pdf():
return submit(_that.imagePaths,_that.outputName);case ImagePickRequested():
return pickRequested();case ImagePicked():
return picked(_that.paths);case ImageRemoveAt():
return removeAt(_that.index);case ImageReordered():
return reordered(_that.fromIndex,_that.toIndex);case ImageClearSelection():
return clearSelection();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<String> imagePaths,  String? outputName)?  submit,TResult? Function()?  pickRequested,TResult? Function( List<String> paths)?  picked,TResult? Function( int index)?  removeAt,TResult? Function( int fromIndex,  int toIndex)?  reordered,TResult? Function()?  clearSelection,}) {final _that = this;
switch (_that) {
case SubmitImage2Pdf() when submit != null:
return submit(_that.imagePaths,_that.outputName);case ImagePickRequested() when pickRequested != null:
return pickRequested();case ImagePicked() when picked != null:
return picked(_that.paths);case ImageRemoveAt() when removeAt != null:
return removeAt(_that.index);case ImageReordered() when reordered != null:
return reordered(_that.fromIndex,_that.toIndex);case ImageClearSelection() when clearSelection != null:
return clearSelection();case _:
  return null;

}
}

}

/// @nodoc


class SubmitImage2Pdf implements Image2PdfMutationEvent {
  const SubmitImage2Pdf(this.imagePaths, {this.outputName});
  

 final  List<String> imagePaths;
 final  String? outputName;

/// Create a copy of Image2PdfMutationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubmitImage2PdfCopyWith<SubmitImage2Pdf> get copyWith => _$SubmitImage2PdfCopyWithImpl<SubmitImage2Pdf>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SubmitImage2Pdf&&const DeepCollectionEquality().equals(other.imagePaths, imagePaths)&&(identical(other.outputName, outputName) || other.outputName == outputName));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(imagePaths),outputName);
}

@override
String toString() {
    return 'Image2PdfMutationEvent.submit(imagePaths: $imagePaths, outputName: $outputName)';
}


}

/// @nodoc
abstract mixin class $SubmitImage2PdfCopyWith<$Res> implements $Image2PdfMutationEventCopyWith<$Res> {
  factory $SubmitImage2PdfCopyWith(SubmitImage2Pdf value, $Res Function(SubmitImage2Pdf) _then) = _$SubmitImage2PdfCopyWithImpl;
@useResult
$Res call({
 List<String> imagePaths, String? outputName
});




}
/// @nodoc
class _$SubmitImage2PdfCopyWithImpl<$Res>
    implements $SubmitImage2PdfCopyWith<$Res> {
  _$SubmitImage2PdfCopyWithImpl(this._self, this._then);

  final SubmitImage2Pdf _self;
  final $Res Function(SubmitImage2Pdf) _then;

/// Create a copy of Image2PdfMutationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? imagePaths = null,Object? outputName = freezed,}) {
  return _then(SubmitImage2Pdf(
null == imagePaths ? _self.imagePaths : imagePaths // ignore: cast_nullable_to_non_nullable
as List<String>,outputName: freezed == outputName ? _self.outputName : outputName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class ImagePickRequested implements Image2PdfMutationEvent {
  const ImagePickRequested();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ImagePickRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'Image2PdfMutationEvent.pickRequested()';
}


}




/// @nodoc


class ImagePicked implements Image2PdfMutationEvent {
  const ImagePicked(this.paths);
  

 final  List<String> paths;

/// Create a copy of Image2PdfMutationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImagePickedCopyWith<ImagePicked> get copyWith => _$ImagePickedCopyWithImpl<ImagePicked>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ImagePicked&&const DeepCollectionEquality().equals(other.paths, paths));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(paths));
}

@override
String toString() {
    return 'Image2PdfMutationEvent.picked(paths: $paths)';
}


}

/// @nodoc
abstract mixin class $ImagePickedCopyWith<$Res> implements $Image2PdfMutationEventCopyWith<$Res> {
  factory $ImagePickedCopyWith(ImagePicked value, $Res Function(ImagePicked) _then) = _$ImagePickedCopyWithImpl;
@useResult
$Res call({
 List<String> paths
});




}
/// @nodoc
class _$ImagePickedCopyWithImpl<$Res>
    implements $ImagePickedCopyWith<$Res> {
  _$ImagePickedCopyWithImpl(this._self, this._then);

  final ImagePicked _self;
  final $Res Function(ImagePicked) _then;

/// Create a copy of Image2PdfMutationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? paths = null,}) {
  return _then(ImagePicked(
null == paths ? _self.paths : paths // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class ImageRemoveAt implements Image2PdfMutationEvent {
  const ImageRemoveAt(this.index);
  

 final  int index;

/// Create a copy of Image2PdfMutationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageRemoveAtCopyWith<ImageRemoveAt> get copyWith => _$ImageRemoveAtCopyWithImpl<ImageRemoveAt>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageRemoveAt&&(identical(other.index, index) || other.index == index));
}


@override
int get hashCode {
    return Object.hash(runtimeType,index);
}

@override
String toString() {
    return 'Image2PdfMutationEvent.removeAt(index: $index)';
}


}

/// @nodoc
abstract mixin class $ImageRemoveAtCopyWith<$Res> implements $Image2PdfMutationEventCopyWith<$Res> {
  factory $ImageRemoveAtCopyWith(ImageRemoveAt value, $Res Function(ImageRemoveAt) _then) = _$ImageRemoveAtCopyWithImpl;
@useResult
$Res call({
 int index
});




}
/// @nodoc
class _$ImageRemoveAtCopyWithImpl<$Res>
    implements $ImageRemoveAtCopyWith<$Res> {
  _$ImageRemoveAtCopyWithImpl(this._self, this._then);

  final ImageRemoveAt _self;
  final $Res Function(ImageRemoveAt) _then;

/// Create a copy of Image2PdfMutationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? index = null,}) {
  return _then(ImageRemoveAt(
null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ImageReordered implements Image2PdfMutationEvent {
  const ImageReordered(this.fromIndex, this.toIndex);
  

 final  int fromIndex;
 final  int toIndex;

/// Create a copy of Image2PdfMutationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageReorderedCopyWith<ImageReordered> get copyWith => _$ImageReorderedCopyWithImpl<ImageReordered>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageReordered&&(identical(other.fromIndex, fromIndex) || other.fromIndex == fromIndex)&&(identical(other.toIndex, toIndex) || other.toIndex == toIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,fromIndex,toIndex);
}

@override
String toString() {
    return 'Image2PdfMutationEvent.reordered(fromIndex: $fromIndex, toIndex: $toIndex)';
}


}

/// @nodoc
abstract mixin class $ImageReorderedCopyWith<$Res> implements $Image2PdfMutationEventCopyWith<$Res> {
  factory $ImageReorderedCopyWith(ImageReordered value, $Res Function(ImageReordered) _then) = _$ImageReorderedCopyWithImpl;
@useResult
$Res call({
 int fromIndex, int toIndex
});




}
/// @nodoc
class _$ImageReorderedCopyWithImpl<$Res>
    implements $ImageReorderedCopyWith<$Res> {
  _$ImageReorderedCopyWithImpl(this._self, this._then);

  final ImageReordered _self;
  final $Res Function(ImageReordered) _then;

/// Create a copy of Image2PdfMutationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fromIndex = null,Object? toIndex = null,}) {
  return _then(ImageReordered(
null == fromIndex ? _self.fromIndex : fromIndex // ignore: cast_nullable_to_non_nullable
as int,null == toIndex ? _self.toIndex : toIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ImageClearSelection implements Image2PdfMutationEvent {
  const ImageClearSelection();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageClearSelection);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'Image2PdfMutationEvent.clearSelection()';
}


}




// dart format on
