//! Code generation output infrastructure.
//!
//! Provides a [`CodeWriter`] that builds source code strings with proper formatting,
//! and a [`FileEmitter`] that writes generated code to the filesystem.

use std::fmt::Write as _;
use std::fs;
use std::path::{Path, PathBuf};

/// Builds a source code string incrementally with indentation tracking.
#[derive(Debug, Default)]
pub struct CodeWriter {
    buffer: String,
    indent_level: usize,
    indent_str: String,
}

impl CodeWriter {
    pub fn new() -> Self {
        Self {
            buffer: String::with_capacity(8192),
            indent_level: 0,
            indent_str: String::new(),
        }
    }

    /// Write a line with current indentation.
    pub fn line(&mut self, text: &str) {
        self.buffer.push_str(&self.indent_str);
        self.buffer.push_str(text);
        self.buffer.push('\n');
    }

    /// Write a formatted line with current indentation.
    pub fn line_fmt(&mut self, args: std::fmt::Arguments<'_>) {
        self.buffer.push_str(&self.indent_str);
        let _ = self.buffer.write_fmt(args);
        self.buffer.push('\n');
    }

    /// Write a blank line.
    pub fn blank_line(&mut self) {
        self.buffer.push('\n');
    }

    /// Write raw text without indentation or newline.
    pub fn raw(&mut self, text: &str) {
        self.buffer.push_str(text);
    }

    /// Write raw text with a trailing newline but no indentation.
    pub fn raw_line(&mut self, text: &str) {
        self.buffer.push_str(text);
        self.buffer.push('\n');
    }

    /// Increase indentation level.
    pub fn indent(&mut self) {
        self.indent_level += 1;
        self.indent_str = "  ".repeat(self.indent_level);
    }

    /// Decrease indentation level.
    pub fn dedent(&mut self) {
        self.indent_level = self.indent_level.saturating_sub(1);
        self.indent_str = "  ".repeat(self.indent_level);
    }

    /// Consume the writer and return the built string.
    pub fn finish(self) -> String {
        self.buffer
    }
}

/// Writes generated code files to a framework output directory.
pub struct FileEmitter {
    base_dir: PathBuf,
}

impl FileEmitter {
    /// Create a new emitter targeting `base_dir/{framework_lowercase}/`.
    pub fn new(output_dir: &Path, framework_name: &str) -> std::io::Result<Self> {
        let base_dir = output_dir.join(framework_name.to_ascii_lowercase());
        fs::create_dir_all(&base_dir)?;
        Ok(Self { base_dir })
    }

    /// Write a file in the framework directory.
    pub fn write_file(&self, filename: &str, content: &str) -> std::io::Result<()> {
        let path = self.base_dir.join(filename);
        fs::write(&path, content)
    }

    /// Write a file in a subdirectory (e.g., "protocols/").
    pub fn write_subdir_file(
        &self,
        subdir: &str,
        filename: &str,
        content: &str,
    ) -> std::io::Result<()> {
        let dir = self.base_dir.join(subdir);
        fs::create_dir_all(&dir)?;
        fs::write(dir.join(filename), content)
    }

    /// Get the base directory path.
    pub fn base_dir(&self) -> &Path {
        &self.base_dir
    }
}

/// Convenience macro for writing formatted lines to a [`CodeWriter`].
///
/// Usage: `write_line!(writer, "text {} here", value);`
#[macro_export]
macro_rules! write_line {
    ($writer:expr, $($arg:tt)*) => {
        $writer.line_fmt(format_args!($($arg)*))
    };
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_code_writer_basic() {
        let mut w = CodeWriter::new();
        w.line("#lang racket/base");
        w.blank_line();
        w.line("(define (foo x)");
        w.indent();
        w.line("(+ x 1))");
        w.dedent();
        let result = w.finish();
        assert_eq!(result, "#lang racket/base\n\n(define (foo x)\n  (+ x 1))\n");
    }

    #[test]
    fn test_code_writer_line_fmt() {
        let mut w = CodeWriter::new();
        write_line!(w, "(define {} {})", "x", 42);
        assert_eq!(w.finish(), "(define x 42)\n");
    }

    #[test]
    fn test_code_writer_nested_indent() {
        let mut w = CodeWriter::new();
        w.line("level 0");
        w.indent();
        w.line("level 1");
        w.indent();
        w.line("level 2");
        w.dedent();
        w.line("level 1 again");
        w.dedent();
        w.line("level 0 again");
        assert_eq!(
            w.finish(),
            "level 0\n  level 1\n    level 2\n  level 1 again\nlevel 0 again\n"
        );
    }

    #[test]
    fn test_code_writer_raw() {
        let mut w = CodeWriter::new();
        w.indent();
        w.raw("no indent");
        w.raw_line(" still raw");
        w.line("indented");
        assert_eq!(w.finish(), "no indent still raw\n  indented\n");
    }

    #[test]
    fn test_dedent_does_not_underflow() {
        let mut w = CodeWriter::new();
        w.dedent();
        w.dedent();
        w.line("still at zero");
        assert_eq!(w.finish(), "still at zero\n");
    }

    #[test]
    fn test_file_emitter_creates_directory() {
        let tmp = tempfile::tempdir().unwrap();
        let emitter = FileEmitter::new(tmp.path(), "Foundation").unwrap();
        assert!(emitter.base_dir().ends_with("foundation"));
        assert!(emitter.base_dir().exists());
    }

    #[test]
    fn test_file_emitter_write_and_read() {
        let tmp = tempfile::tempdir().unwrap();
        let emitter = FileEmitter::new(tmp.path(), "AppKit").unwrap();
        emitter.write_file("test.rkt", "#lang racket\n").unwrap();
        let content = fs::read_to_string(emitter.base_dir().join("test.rkt")).unwrap();
        assert_eq!(content, "#lang racket\n");
    }

    #[test]
    fn test_file_emitter_subdir() {
        let tmp = tempfile::tempdir().unwrap();
        let emitter = FileEmitter::new(tmp.path(), "AppKit").unwrap();
        emitter
            .write_subdir_file("protocols", "delegate.rkt", ";; delegate\n")
            .unwrap();
        let content =
            fs::read_to_string(emitter.base_dir().join("protocols/delegate.rkt")).unwrap();
        assert_eq!(content, ";; delegate\n");
    }
}
