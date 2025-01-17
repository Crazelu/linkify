import 'package:linkify/linkify.dart';

final _emailRegex = RegExp(
  r'^(.*?)((mailto:)?[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z][A-Z]+)',
  caseSensitive: false,
  dotAll: true,
);

class EmailLinkifier extends Linkifier {
  const EmailLinkifier();

  @override
  List<LinkifyElement> parse(elements, options) {
    final list = <LinkifyElement>[];

    elements.forEach((element) {
      if (element is TextElement) {
        final match = _emailRegex.firstMatch(element.text);

        if (match == null) {
          list.add(element);
        } else {
          final text = element.text.replaceFirst(match.group(0)!, '');

          if (match.group(1)?.isNotEmpty == true) {
            list.add(TextElement(match.group(1)!));
          }

          if (match.group(2)?.isNotEmpty == true) {
            // Always humanize emails
            list.add(EmailElement(
              match.group(2)!.replaceFirst(RegExp(r'mailto:'), ''),
            ));
          }

          if (text.isNotEmpty) {
            list.addAll(parse([TextElement(text)], options));
          }
        }
      } else {
        list.add(element);
      }
    });

    return list;
  }

  @override
  Future<List<LinkifyElement>> asyncParse(
    List<LinkifyElement> elements,
    LinkifyOptions options,
  ) async {
    return parse(elements, options);
  }
}

/// Represents an element containing an email address
class EmailElement extends LinkifyElement {
  String _url;
  final String emailAddress;
  String get url => _url;

  EmailElement(this.emailAddress)
      : _url = 'mailto:$emailAddress',
        super(emailAddress);

  factory EmailElement.fromMap(Map<String, dynamic> map) {
    return EmailElement(map['emailAddress']!);
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': 'EmailElement',
        'emailAddress': emailAddress,
      };

  @override
  String toString() {
    return "EmailElement: '$emailAddress' ($text)";
  }

  @override
  bool operator ==(other) => equals(other);

  @override
  bool equals(other) =>
      other is EmailElement &&
      super.equals(other) &&
      other.emailAddress == emailAddress;
}
