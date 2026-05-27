#lang racket/base
;; Generated protocol definition for NSTableViewDelegate (AppKit)
;; Do not edit — regenerate from enriched IR
;;
;; NSTableViewDelegate defines 31 methods:
;;   void-returning (13):
;;     tableView:didAddRowView:forRow:  (tableView:NSTableView, rowView:NSTableRowView, row:int64)
;;     tableView:didRemoveRowView:forRow:  (tableView:NSTableView, rowView:NSTableRowView, row:int64)
;;     tableView:willDisplayCell:forTableColumn:row:  (tableView:NSTableView, cell:id, tableColumn:NSTableColumn, row:int64)
;;     tableView:mouseDownInHeaderOfTableColumn:  (tableView:NSTableView, tableColumn:NSTableColumn)
;;     tableView:didClickTableColumn:  (tableView:NSTableView, tableColumn:NSTableColumn)
;;     tableView:didDragTableColumn:  (tableView:NSTableView, tableColumn:NSTableColumn)
;;     tableView:heightOfRow:  (tableView:NSTableView, row:int64)
;;     tableView:sizeToFitWidthOfColumn:  (tableView:NSTableView, column:int64)
;;     tableView:userDidChangeVisibilityOfTableColumns:  (tableView:NSTableView, columns:id)
;;     tableViewSelectionDidChange:  (notification:NSNotification)
;;     tableViewColumnDidMove:  (notification:NSNotification)
;;     tableViewColumnDidResize:  (notification:NSNotification)
;;     tableViewSelectionIsChanging:  (notification:NSNotification)
;;   bool-returning (10):
;;     tableView:shouldEditTableColumn:row:  (tableView:NSTableView, tableColumn:NSTableColumn, row:int64)
;;     tableView:shouldShowCellExpansionForTableColumn:row:  (tableView:NSTableView, tableColumn:NSTableColumn, row:int64)
;;     tableView:shouldTrackCell:forTableColumn:row:  (tableView:NSTableView, cell:NSCell, tableColumn:NSTableColumn, row:int64)
;;     selectionShouldChangeInTableView:  (tableView:NSTableView)
;;     tableView:shouldSelectRow:  (tableView:NSTableView, row:int64)
;;     tableView:shouldSelectTableColumn:  (tableView:NSTableView, tableColumn:NSTableColumn)
;;     tableView:shouldTypeSelectForEvent:withCurrentSearchString:  (tableView:NSTableView, event:NSEvent, searchString:NSString)
;;     tableView:isGroupRow:  (tableView:NSTableView, row:int64)
;;     tableView:shouldReorderColumn:toColumn:  (tableView:NSTableView, columnIndex:int64, newColumnIndex:int64)
;;     tableView:userCanChangeVisibilityOfTableColumn:  (tableView:NSTableView, column:NSTableColumn)
;;   id-returning (7):
;;     tableView:viewForTableColumn:row:  (tableView:NSTableView, tableColumn:NSTableColumn, row:int64)
;;     tableView:rowViewForRow:  (tableView:NSTableView, row:int64)
;;     tableView:toolTipForCell:rect:tableColumn:row:mouseLocation:  (tableView:NSTableView, cell:NSCell, rect:pointer, tableColumn:NSTableColumn, row:int64, mouseLocation:NSPoint)
;;     tableView:dataCellForTableColumn:row:  (tableView:NSTableView, tableColumn:NSTableColumn, row:int64)
;;     tableView:selectionIndexesForProposedSelection:  (tableView:NSTableView, proposedSelectionIndexes:NSIndexSet)
;;     tableView:typeSelectStringForTableColumn:row:  (tableView:NSTableView, tableColumn:NSTableColumn, row:int64)
;;     tableView:rowActionsForRow:edge:  (tableView:NSTableView, row:int64, edge:NSTableRowActionEdge)
;;   long-returning (1):
;;     tableView:nextTypeSelectMatchFromRow:toRow:forString:  (tableView:NSTableView, startRow:int64, endRow:int64, searchString:NSString)

(require racket/contract
         "../../../runtime/delegate.rkt")

(provide/contract
  [make-nstableviewdelegate (->* () () #:rest (listof (or/c string? procedure?)) any/c)]
  [nstableviewdelegate-selectors (listof string?)])

;; All selectors in this protocol
(define nstableviewdelegate-selectors
  '("tableView:viewForTableColumn:row:"
    "tableView:rowViewForRow:"
    "tableView:didAddRowView:forRow:"
    "tableView:didRemoveRowView:forRow:"
    "tableView:willDisplayCell:forTableColumn:row:"
    "tableView:shouldEditTableColumn:row:"
    "tableView:toolTipForCell:rect:tableColumn:row:mouseLocation:"
    "tableView:shouldShowCellExpansionForTableColumn:row:"
    "tableView:shouldTrackCell:forTableColumn:row:"
    "tableView:dataCellForTableColumn:row:"
    "selectionShouldChangeInTableView:"
    "tableView:shouldSelectRow:"
    "tableView:selectionIndexesForProposedSelection:"
    "tableView:shouldSelectTableColumn:"
    "tableView:mouseDownInHeaderOfTableColumn:"
    "tableView:didClickTableColumn:"
    "tableView:didDragTableColumn:"
    "tableView:heightOfRow:"
    "tableView:typeSelectStringForTableColumn:row:"
    "tableView:nextTypeSelectMatchFromRow:toRow:forString:"
    "tableView:shouldTypeSelectForEvent:withCurrentSearchString:"
    "tableView:isGroupRow:"
    "tableView:sizeToFitWidthOfColumn:"
    "tableView:shouldReorderColumn:toColumn:"
    "tableView:rowActionsForRow:edge:"
    "tableView:userCanChangeVisibilityOfTableColumn:"
    "tableView:userDidChangeVisibilityOfTableColumns:"
    "tableViewSelectionDidChange:"
    "tableViewColumnDidMove:"
    "tableViewColumnDidResize:"
    "tableViewSelectionIsChanging:"))

;; Create a NSTableViewDelegate delegate.
;; Pass selector string → handler procedure pairs.
;; Example:
;;   (make-nstableviewdelegate
;;     "tableView:didAddRowView:forRow:" (lambda (table-view row-view row) ...)
;;     "tableView:shouldEditTableColumn:row:" (lambda (table-view table-column row) ... #t)
;;   )
(define (make-nstableviewdelegate . selector+handler-pairs)
  (apply make-delegate
    #:return-types
    (hash "tableView:shouldEditTableColumn:row:" 'bool "tableView:shouldShowCellExpansionForTableColumn:row:" 'bool "tableView:shouldTrackCell:forTableColumn:row:" 'bool "selectionShouldChangeInTableView:" 'bool "tableView:shouldSelectRow:" 'bool "tableView:shouldSelectTableColumn:" 'bool "tableView:shouldTypeSelectForEvent:withCurrentSearchString:" 'bool "tableView:isGroupRow:" 'bool "tableView:shouldReorderColumn:toColumn:" 'bool "tableView:userCanChangeVisibilityOfTableColumn:" 'bool "tableView:viewForTableColumn:row:" 'id "tableView:rowViewForRow:" 'id "tableView:toolTipForCell:rect:tableColumn:row:mouseLocation:" 'id "tableView:dataCellForTableColumn:row:" 'id "tableView:selectionIndexesForProposedSelection:" 'id "tableView:typeSelectStringForTableColumn:row:" 'id "tableView:rowActionsForRow:edge:" 'id "tableView:nextTypeSelectMatchFromRow:toRow:forString:" 'long)
    #:param-types
    (hash "tableView:viewForTableColumn:row:" '(object object long) "tableView:rowViewForRow:" '(object long) "tableView:didAddRowView:forRow:" '(object object long) "tableView:didRemoveRowView:forRow:" '(object object long) "tableView:willDisplayCell:forTableColumn:row:" '(object object object long) "tableView:shouldEditTableColumn:row:" '(object object long) "tableView:toolTipForCell:rect:tableColumn:row:mouseLocation:" '(object object pointer object long pointer) "tableView:shouldShowCellExpansionForTableColumn:row:" '(object object long) "tableView:shouldTrackCell:forTableColumn:row:" '(object object object long) "tableView:dataCellForTableColumn:row:" '(object object long) "selectionShouldChangeInTableView:" '(object) "tableView:shouldSelectRow:" '(object long) "tableView:selectionIndexesForProposedSelection:" '(object object) "tableView:shouldSelectTableColumn:" '(object object) "tableView:mouseDownInHeaderOfTableColumn:" '(object object) "tableView:didClickTableColumn:" '(object object) "tableView:didDragTableColumn:" '(object object) "tableView:heightOfRow:" '(object long) "tableView:typeSelectStringForTableColumn:row:" '(object object long) "tableView:nextTypeSelectMatchFromRow:toRow:forString:" '(object long long object) "tableView:shouldTypeSelectForEvent:withCurrentSearchString:" '(object object object) "tableView:isGroupRow:" '(object long) "tableView:sizeToFitWidthOfColumn:" '(object long) "tableView:shouldReorderColumn:toColumn:" '(object long long) "tableView:rowActionsForRow:edge:" '(object long pointer) "tableView:userCanChangeVisibilityOfTableColumn:" '(object object) "tableView:userDidChangeVisibilityOfTableColumns:" '(object object) "tableViewSelectionDidChange:" '(object) "tableViewColumnDidMove:" '(object) "tableViewColumnDidResize:" '(object) "tableViewSelectionIsChanging:" '(object))
    selector+handler-pairs))
