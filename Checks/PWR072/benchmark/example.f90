! PWR072: Explicitly declare the 'save' attribute or split the variable
!         initialization to prevent unintended behavior

module utils
  implicit none
contains
function compute_next_moving_average_f(xi) result(new_average)
  use iso_c_binding, only : c_double, c_int

  implicit none
  real(kind=c_double) :: new_average
  real(kind=c_double), intent(in) :: xi

  integer(kind=c_int) :: num_processed_elements = 0
  real(kind=c_double) :: moving_average = 0.0
  
  real(kind=c_double) :: alpha

  num_processed_elements = num_processed_elements + 1
  alpha = 1.0 / num_processed_elements
  moving_average = (1.0 - alpha) * moving_average + alpha * xi

  new_average = moving_average
end function compute_next_moving_average_f
end module utils

function compute_final_moving_average_f(n, X) bind(c)
  use iso_c_binding, only : c_double, c_int
  use utils, only : compute_next_moving_average_f

  implicit none

  integer(kind=c_int), intent(in), value :: n
  real(kind=c_double) :: compute_final_moving_average_f
  real(kind=c_double), dimension(n), intent(in) :: X

  integer(kind=c_int) :: i
  real(kind=c_double) :: moving_average

  do i = 1, n
    moving_average = compute_next_moving_average_f(X(i))
  end do

  compute_final_moving_average_f = moving_average
end function compute_final_moving_average_f
