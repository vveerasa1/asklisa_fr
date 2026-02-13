import 'package:flutter/material.dart';
import '../const/colors.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final String? label;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    required this.hint,
    this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.validator,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textGrey,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLines: maxLines,
            enabled: enabled,
            onChanged: onChanged,
            validator: validator,
            focusNode: focusNode,
            style: const TextStyle(
              color: textWhite,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 16, right: 12),
                      child: Icon(prefixIcon, color: textMuted, size: 22),
                    )
                  : null,
              suffixIcon: suffixIcon != null
                  ? GestureDetector(
                      onTap: onSuffixTap,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child:
                            Icon(suffixIcon, color: primaryTeal, size: 22),
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
