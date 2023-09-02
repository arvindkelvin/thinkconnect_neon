import 'package:code_builder/code_builder.dart';
import 'package:dynamite/src/builder/resolve_type.dart';
import 'package:dynamite/src/builder/state.dart';
import 'package:dynamite/src/helpers/dart_helpers.dart';
import 'package:dynamite/src/helpers/dynamite.dart';
import 'package:dynamite/src/models/open_api.dart';
import 'package:dynamite/src/models/schema.dart';
import 'package:dynamite/src/type_result/type_result.dart';

Spec buildHeaderSerializer(final State state, final String identifier, final OpenAPI spec, final Schema schema) =>
    Class(
      (final b) => b
        ..name = '_\$${state.classPrefix}${identifier}Serializer'
        ..implements.add(refer('StructuredSerializer<${state.classPrefix}$identifier>'))
        ..fields.addAll([
          Field(
            (final b) => b
              ..name = 'types'
              ..modifier = FieldModifier.final$
              ..type = refer('Iterable<Type>')
              ..annotations.add(refer('override'))
              ..assignment = Code('const [${state.classPrefix}$identifier, _\$${state.classPrefix}$identifier]'),
          ),
          Field(
            (final b) => b
              ..name = 'wireName'
              ..modifier = FieldModifier.final$
              ..type = refer('String')
              ..annotations.add(refer('override'))
              ..assignment = Code("r'${state.classPrefix}$identifier'"),
          ),
        ])
        ..methods.addAll([
          Method((final b) {
            b
              ..name = 'serialize'
              ..returns = refer('Iterable<Object?>')
              ..annotations.add(refer('override'))
              ..requiredParameters.addAll([
                Parameter(
                  (final b) => b
                    ..name = 'serializers'
                    ..type = refer('Serializers'),
                ),
                Parameter(
                  (final b) => b
                    ..name = 'object'
                    ..type = refer('${state.classPrefix}$identifier'),
                ),
              ])
              ..optionalParameters.add(
                Parameter(
                  (final b) => b
                    ..name = 'specifiedType'
                    ..type = refer('FullType')
                    ..named = true
                    ..defaultTo = const Code('FullType.unspecified'),
                ),
              )
              ..body = const Code('throw UnimplementedError();');
          }),
          Method((final b) {
            b
              ..name = 'deserialize'
              ..returns = refer('${state.classPrefix}$identifier')
              ..annotations.add(refer('override'))
              ..requiredParameters.addAll([
                Parameter(
                  (final b) => b
                    ..name = 'serializers'
                    ..type = refer('Serializers'),
                ),
                Parameter(
                  (final b) => b
                    ..name = 'serialized'
                    ..type = refer('Iterable<Object?>'),
                ),
              ])
              ..optionalParameters.add(
                Parameter(
                  (final b) => b
                    ..name = 'specifiedType'
                    ..type = refer('FullType')
                    ..named = true
                    ..defaultTo = const Code('FullType.unspecified'),
                ),
              );
            List<Code> deserializeProperty(final MapEntry<String, Schema> property) {
              final propertyName = property.key;
              final propertySchema = property.value;
              final result = resolveType(
                spec,
                state,
                '${identifier}_${toDartName(propertyName, uppercaseFirstCharacter: true)}',
                propertySchema,
                nullable: isDartParameterNullable(schema.required?.contains(propertyName), propertySchema),
              );

              return [
                Code("case '$propertyName':"),
                if (result.className != 'String') ...[
                  if (result is TypeResultBase || result is TypeResultEnum) ...[
                    Code(
                      'result.${toDartName(propertyName)} = ${result.deserialize(result.decode('value!'))};',
                    ),
                  ] else ...[
                    Code(
                      'result.${toDartName(propertyName)}.replace(${result.deserialize(result.decode('value!'))});',
                    ),
                  ],
                ] else ...[
                  Code(
                    'result.${toDartName(propertyName)} = value!;',
                  ),
                ],
              ];
            }

            b.body = Block.of([
              Code('final result = new ${state.classPrefix}${identifier}Builder();'),
              const Code(''),
              const Code('final iterator = serialized.iterator;'),
              const Code('while (iterator.moveNext()) {'),
              const Code('final key = iterator.current! as String;'),
              const Code('iterator.moveNext();'),
              const Code('final value = iterator.current! as String;'),
              const Code('switch (key) {'),
              for (final property in schema.properties!.entries) ...deserializeProperty(property),
              const Code('}'),
              const Code('}'),
              const Code(''),
              const Code('return result.build();'),
            ]);
          }),
        ]),
    );
