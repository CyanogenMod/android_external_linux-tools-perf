# Copyright (C) 2013 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_PRODUCT),sdk)
supported_platforms := none
else
# TODO Clang is having issues with elfutils - only compile on linux-x86 for now
supported_platforms := linux-x86
endif

cur_platform := $(filter $(HOST_OS)-$(HOST_ARCH),$(supported_platforms))

ifdef cur_platform

#
# target libperf
#
libperf_src_files := \
	arch/common.c \
	arch/$(TARGET_ARCH)/util/dwarf-regs.c \
	tests/attr.c \
	ui/helpline.c \
	ui/hist.c \
	ui/progress.c \
	ui/setup.c \
	ui/stdio/hist.c \
	ui/util.c \
	util/abspath.c \
	util/alias.c \
	util/annotate.c \
	util/bitmap.c \
	util/build-id.c \
	util/callchain.c \
	util/cgroup.c \
	util/color.c \
	util/config.c \
	util/config.c \
	util/cpumap.c \
	util/ctype.c \
	util/debug.c \
	util/dso.c \
	util/dwarf-aux.c \
	util/environment.c \
	util/event.c \
	util/evlist.c \
	util/evsel.c \
	util/exec_cmd.c \
	util/header.c \
	util/help.c \
	util/hist.c \
	util/hweight.c \
	util/intlist.c \
	util/levenshtein.c \
	util/machine.c \
	util/map.c \
	util/pager.c \
	util/parse-events.c \
	util/parse-events-bison.c \
	util/parse-events-flex.c \
	util/parse-options.c \
	util/path.c \
	util/pmu.c \
	util/pmu-bison.c \
	util/pmu-flex.c \
	util/probe-event.c \
	util/probe-finder.c \
	util/quote.c \
	util/rblist.c \
	util/record.c \
	util/run-command.c \
	util/sigchain.c \
	util/session.c \
	util/sort.c \
	util/stat.c \
	util/strbuf.c \
	util/string.c \
	util/strfilter.c \
	util/strlist.c \
	util/svghelper.c \
	util/symbol.c \
	util/sysfs.c \
	util/target.c \
	util/thread.c \
	util/thread_map.c \
	util/top.c \
	util/trace-event-info.c \
	util/trace-event-parse.c \
	util/trace-event-read.c \
	util/trace-event-scripting.c \
	util/usage.c \
	util/util.c \
	util/values.c \
	util/vdso.c \
	util/wrapper.c \
	util/xyarray.c \
	../lib/lk/debugfs.c \
	../lib/traceevent/event-parse.c \
	../lib/traceevent/parse-utils.c \
	../lib/traceevent/trace-seq.c \
	../../lib/rbtree.c

common_perf_headers := $(LOCAL_PATH)/../lib $(LOCAL_PATH)/util/include \
	$(LOCAL_PATH)/util $(LOCAL_PATH)/../../include/uapi

common_elfutil_headers := external/elfutils external/elfutils/libelf \
	external/elfutils/libdw external/elfutils/libdwfl

common_compiler_flags := -Wno-pointer-arith -Wno-attributes -Wno-error \
	-Wno-unused-parameter -Wno-error=return-type -std=gnu99

common_disabled_macros := -DNO_NEWT_SUPPORT -DNO_LIBPERL -DNO_LIBPYTHON \
	-DNO_GTK2 -DNO_LIBNUMA -DNO_LIBAUDIT

common_predefined_macros := -DDWARF_SUPPORT -DPYTHON='""' -DBINDIR='""' \
	-DETC_PERFCONFIG='""' -DPREFIX='""' -DPERF_EXEC_PATH='""' \
	-DPERF_HTML_PATH='""' -DPERF_MAN_PATH='""' -DPERF_INFO_PATH='""' \
	-DPERF_VERSION='"perf.3.12_android"'

include $(CLEAR_VARS)

LOCAL_SRC_FILES := $(libperf_src_files)

# TODO on-device symbolization is having issues as samples are attributed to
# wrong DSOs
LOCAL_SRC_FILES += util/symbol-minimal.c

# disable modules not used by Android
LOCAL_CFLAGS := $(common_disabled_macros)

# predefined macros
LOCAL_CFLAGS += $(common_predefined_macros)

LOCAL_CFLAGS += $(common_compiler_flags)

LOCAL_C_INCLUDES := $(common_perf_headers) $(common_elfutil_headers)

LOCAL_MODULE := libperf

LOCAL_MODULE_TAGS := eng

include $(BUILD_STATIC_LIBRARY)

#
# host libperf
#
include $(CLEAR_VARS)

LOCAL_SRC_FILES := $(libperf_src_files)

# perform symbolization on the host
LOCAL_SRC_FILES += util/symbol-elf.c

# disable modules not used by Android
LOCAL_CFLAGS := $(common_disabled_macros)

# predefined macros
LOCAL_CFLAGS += $(common_predefined_macros)

# needed by symbolization
LOCAL_CFLAGS += -DLIBELF_SUPPORT

LOCAL_CFLAGS += $(common_compiler_flags)

LOCAL_C_INCLUDES := $(common_perf_headers) $(common_elfutil_headers)

LOCAL_MODULE := libperf

LOCAL_MODULE_TAGS := eng

include $(BUILD_HOST_STATIC_LIBRARY)

#
# target perf
#
perf_src_files := \
	perf.c \
	builtin-annotate.c \
	builtin-buildid-cache.c \
	builtin-buildid-list.c \
	builtin-diff.c \
	builtin-evlist.c \
	builtin-help.c \
	builtin-inject.c \
	builtin-kmem.c \
	builtin-list.c \
	builtin-lock.c \
	builtin-mem.c \
	builtin-probe.c \
	builtin-record.c \
	builtin-sched.c \
	builtin-script.c \
	builtin-stat.c \
	builtin-timechart.c \
	builtin-report.c \
	builtin-top.c

include $(CLEAR_VARS)

LOCAL_SRC_FILES := $(perf_src_files)

LOCAL_STATIC_LIBRARIES := libperf libc libm
LOCAL_STATIC_LIBRARIES += libdwfl libdw libebl libelf libgccdemangle

# disable modules not used by Android
LOCAL_CFLAGS := $(common_disabled_macros)

# predefined macros
LOCAL_CFLAGS += $(common_predefined_macros)

LOCAL_CFLAGS += $(common_compiler_flags)

LOCAL_C_INCLUDES := $(common_perf_headers) $(common_elfutil_headers)

LOCAL_SHARED_LIBRARIES := libdl

LOCAL_MODULE := perf

LOCAL_MODULE_TAGS := eng

include $(BUILD_EXECUTABLE)

#
# host perf
#
include $(CLEAR_VARS)

LOCAL_SRC_FILES := $(perf_src_files)

LOCAL_STATIC_LIBRARIES := libperf
LOCAL_STATIC_LIBRARIES += libdwfl libdw libebl libelf libgccdemangle

# disable modules not used by Android
LOCAL_CFLAGS := $(common_disabled_macros)

# predefined macros
LOCAL_CFLAGS += $(common_predefined_macros)

# available in host libc
LOCAL_CFLAGS += -DHAVE_ON_EXIT

LOCAL_CFLAGS += $(common_compiler_flags)

LOCAL_C_INCLUDES := $(common_perf_headers) $(common_elfutil_headers)

# for pthread_* and clock_gettime
LOCAL_LDLIBS := -lpthread -lrt -ldl

LOCAL_MODULE := perfhost

LOCAL_MODULE_TAGS := eng

include $(BUILD_HOST_EXECUTABLE)

endif #cur_platform
