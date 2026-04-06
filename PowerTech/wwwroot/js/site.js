// PowerTech Storefront Global Scripts

// Update Cart Badge Count
function updateHeaderCartCount() {
    $.ajax({
        url: '/Store/Cart/GetCartCount',
        type: 'GET',
        cache: false,
        success: function (count) {
            $('.badge-count').text(count);
        }
    });
}

// Global Add to Cart function for Product Cards
function quickAddToCart(productId) {
    $.ajax({
        url: '/Store/Cart/Add',
        type: 'POST',
        data: {
            productId: productId,
            quantity: 1,
            __RequestVerificationToken: $('input[name="__RequestVerificationToken"]').val()
        },
        success: function (res) {
            if (res.success) {
                updateHeaderCartCount();
                Swal.fire({
                    title: 'Thành công!',
                    text: res.message,
                    icon: 'success',
                    toast: true,
                    position: 'top-end',
                    showConfirmButton: false,
                    timer: 3000,
                    timerProgressBar: true
                });
            } else {
                Swal.fire({
                    title: 'Thông báo',
                    text: res.message,
                    icon: 'info',
                    showCancelButton: true,
                    confirmButtonText: 'Đăng nhập ngay',
                    confirmButtonColor: '#D7262E'
                }).then((result) => {
                    if (result.isConfirmed) {
                        window.location.href = '/Identity/Account/Login?returnUrl=' + encodeURIComponent(window.location.pathname);
                    }
                });
            }
        },
        error: function () {
            Swal.fire('Lỗi', 'Không thể thêm sản phẩm, vui lòng thử lại!', 'error');
        }
    });
}

// Initialize tooltips/popovers if needed
$(document).ready(function () {
    updateHeaderCartCount();
});
