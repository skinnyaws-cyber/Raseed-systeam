#!/bin/bash

# 1. تحميل فلاتر من المستودع الرسمي (نسخة مستقرة)
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# 2. إضافة فلاتر لمسار النظام لكي يتعرف عليه Netlify
export PATH="$PATH:`pwd`/flutter/bin"

# 3. تشغيل فلاتر وتجهيزه للويب
flutter doctor
flutter config --enable-web

# 4. بناء المشروع
flutter build web --release
